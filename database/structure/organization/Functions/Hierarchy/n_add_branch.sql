-- =============================================
-- FILE: structure/organization/Functions/Hierarchy/fn_add_branch.sql
-- PURPOSE: دالة إضافة فرع جديد مع تحديث Closure Table
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_add_branch(
    p_branch_code VARCHAR,
    p_branch_name_ar VARCHAR,
    p_branch_type_id INT,
    p_parent_branch_id INT DEFAULT NULL,
    p_created_by BIGINT DEFAULT NULL
) RETURNS INT AS $$
DECLARE
    v_new_branch_id INT;
    v_parent_level INT;
BEGIN
    -- بدء المعاملة
    BEGIN
        -- إدراج الفرع الجديد
        INSERT INTO organization.branches (
            branch_code, 
            branch_name_ar, 
            branch_type_id, 
            parent_branch_id, 
            level,
            created_by
        ) VALUES (
            p_branch_code, 
            p_branch_name_ar, 
            p_branch_type_id, 
            p_parent_branch_id, 
            0,
            p_created_by
        ) RETURNING branch_id INTO v_new_branch_id;
        
        -- تحديث المستوى إذا كان له والد
        IF p_parent_branch_id IS NOT NULL THEN
            SELECT level INTO v_parent_level 
            FROM organization.branches 
            WHERE branch_id = p_parent_branch_id;
            
            UPDATE organization.branches 
            SET level = v_parent_level + 1 
            WHERE branch_id = v_new_branch_id;
        END IF;
        
        -- إضافة العلاقات في Closure Table
        INSERT INTO organization.branch_closure (ancestor, descendant, depth)
        VALUES (v_new_branch_id, v_new_branch_id, 0);
        
        IF p_parent_branch_id IS NOT NULL THEN
            INSERT INTO organization.branch_closure (ancestor, descendant, depth)
            SELECT ancestor, v_new_branch_id, depth + 1
            FROM organization.branch_closure
            WHERE descendant = p_parent_branch_id;
        END IF;
        
        RETURN v_new_branch_id;
    EXCEPTION WHEN OTHERS THEN
        RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION organization.fn_add_branch(VARCHAR, VARCHAR, INT, INT, BIGINT) IS 'إضافة فرع جديد مع تحديث Closure Table';

-- رسالة تأكيد
SELECT '✅ Function fn_add_branch created successfully' AS status;