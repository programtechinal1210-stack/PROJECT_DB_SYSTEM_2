-- =============================================
-- FILE: structure/organization/Functions/Hierarchy/fn_move_branch.sql
-- PURPOSE: دالة نقل فرع إلى أب جديد
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_move_branch(
    p_branch_id INT,
    p_new_parent_id INT,
    p_updated_by BIGINT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_old_parent_id INT;
    v_has_cycle BOOLEAN;
BEGIN
    -- التحقق من عدم وجود دورة
    SELECT EXISTS (
        WITH RECURSIVE descendants AS (
            SELECT branch_id FROM organization.branches WHERE branch_id = p_branch_id
            UNION ALL
            SELECT b.branch_id FROM organization.branches b
            INNER JOIN descendants d ON b.parent_branch_id = d.branch_id
        )
        SELECT 1 FROM descendants WHERE branch_id = p_new_parent_id
    ) INTO v_has_cycle;
    
    IF v_has_cycle THEN
        RAISE EXCEPTION 'لا يمكن نقل الفرع إلى أحد فروعه التابعة';
    END IF;
    
    -- الحصول على الوالد القديم
    SELECT parent_branch_id INTO v_old_parent_id
    FROM organization.branches
    WHERE branch_id = p_branch_id;
    
    -- بدء المعاملة
    BEGIN
        -- تحديث parent_branch_id
        UPDATE organization.branches
        SET parent_branch_id = p_new_parent_id,
            updated_by = p_updated_by,
            updated_at = CURRENT_TIMESTAMP
        WHERE branch_id = p_branch_id;
        
        -- حذف العلاقات القديمة
        DELETE FROM organization.branch_closure
        WHERE descendant IN (
            SELECT descendant 
            FROM organization.branch_closure 
            WHERE ancestor = p_branch_id
        )
        AND ancestor IN (
            SELECT ancestor 
            FROM organization.branch_closure 
            WHERE descendant = p_branch_id 
            AND ancestor != descendant
        );
        
        -- إضافة العلاقات الجديدة
        INSERT INTO organization.branch_closure (ancestor, descendant, depth)
        SELECT ancestor, descendant, 
               (SELECT depth FROM organization.branch_closure WHERE ancestor = a.ancestor AND descendant = p_branch_id) + 
               (SELECT depth FROM organization.branch_closure WHERE ancestor = p_branch_id AND descendant = d.descendant) + 1
        FROM (SELECT ancestor FROM organization.branch_closure WHERE descendant = p_new_parent_id) a
        CROSS JOIN (SELECT descendant FROM organization.branch_closure WHERE ancestor = p_branch_id) d;
        
        RETURN true;
    EXCEPTION WHEN OTHERS THEN
        RAISE;
        RETURN false;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION organization.fn_move_branch(INT, INT, BIGINT) IS 'نقل فرع إلى أب جديد';

-- رسالة تأكيد
SELECT '✅ Function fn_move_branch created successfully' AS status;