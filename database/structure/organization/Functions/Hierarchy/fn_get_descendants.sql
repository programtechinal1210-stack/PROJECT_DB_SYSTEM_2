 
-- =============================================
-- FILE: structure/organization/Functions/Hierarchy/fn_get_descendants.sql
-- PURPOSE: دالة الحصول على جميع الفروع التابعة لفرع معين
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_get_descendants(
    p_ancestor_id INT,
    p_include_self BOOLEAN DEFAULT false,
    p_max_depth INT DEFAULT NULL
) RETURNS TABLE (
    branch_id INT,
    branch_code VARCHAR,
    branch_name_ar VARCHAR,
    depth INT,
    level INT,
    full_path TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.branch_id,
        b.branch_code,
        b.branch_name_ar,
        bc.depth,
        b.level,
        organization.fn_get_branch_path(b.branch_id) AS full_path
    FROM organization.branch_closure bc
    JOIN organization.branches b ON bc.descendant = b.branch_id
    WHERE bc.ancestor = p_ancestor_id
      AND (p_include_self OR bc.depth > 0)
      AND (p_max_depth IS NULL OR bc.depth <= p_max_depth)
    ORDER BY bc.depth, b.branch_name_ar;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION organization.fn_get_descendants(INT, BOOLEAN, INT) IS 'الحصول على جميع الفروع التابعة';

-- رسالة تأكيد
SELECT '✅ Function fn_get_descendants created successfully' AS status;