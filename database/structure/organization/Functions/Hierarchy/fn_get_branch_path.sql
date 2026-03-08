 
-- =============================================
-- FILE: structure/organization/Functions/Hierarchy/fn_get_branch_path.sql
-- PURPOSE: دالة الحصول على مسار الفرع في الشجرة الهرمية
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_get_branch_path(
    p_branch_id INT,
    p_separator VARCHAR DEFAULT ' → '
) RETURNS TEXT AS $$
DECLARE
    v_path TEXT;
BEGIN
    WITH RECURSIVE branch_path AS (
        SELECT 
            branch_id,
            branch_name_ar,
            parent_branch_id,
            1 AS level
        FROM organization.branches
        WHERE branch_id = p_branch_id
        
        UNION ALL
        
        SELECT 
            b.branch_id,
            b.branch_name_ar,
            b.parent_branch_id,
            bp.level + 1
        FROM organization.branches b
        INNER JOIN branch_path bp ON b.branch_id = bp.parent_branch_id
    )
    SELECT array_to_string(array_agg(branch_name_ar ORDER BY level DESC), p_separator)
    INTO v_path
    FROM branch_path;
    
    RETURN v_path;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION organization.fn_get_branch_path(INT, VARCHAR) IS 'الحصول على المسار الكامل للفرع';

-- رسالة تأكيد
SELECT '✅ Function fn_get_branch_path created successfully' AS status;