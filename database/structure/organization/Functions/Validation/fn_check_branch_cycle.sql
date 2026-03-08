 
-- =============================================
-- FILE: structure/organization/Functions/Validation/fn_check_branch_cycle.sql
-- PURPOSE: دالة التحقق من عدم وجود دورة في الشجرة الهرمية
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_check_branch_cycle(
    p_branch_id INT,
    p_new_parent_id INT
) RETURNS TABLE (
    has_cycle BOOLEAN,
    cycle_path TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE descendants AS (
        SELECT 
            branch_id, 
            branch_name_ar, 
            parent_branch_id, 
            1 AS level, 
            branch_name_ar::TEXT AS path
        FROM organization.branches
        WHERE branch_id = p_branch_id
        
        UNION ALL
        
        SELECT 
            b.branch_id,
            b.branch_name_ar,
            b.parent_branch_id,
            d.level + 1,
            d.path || ' → ' || b.branch_name_ar
        FROM organization.branches b
        INNER JOIN descendants d ON b.parent_branch_id = d.branch_id
    )
    SELECT 
        COUNT(*) > 0,
        CASE WHEN COUNT(*) > 0 THEN MIN(path) ELSE NULL END
    FROM descendants
    WHERE branch_id = p_new_parent_id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION organization.fn_check_branch_cycle(INT, INT) IS 'التحقق من عدم وجود دورة في الشجرة الهرمية';

-- رسالة تأكيد
SELECT '✅ Function fn_check_branch_cycle created successfully' AS status;