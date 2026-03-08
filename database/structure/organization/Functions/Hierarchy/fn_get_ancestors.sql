 
-- =============================================
-- FILE: structure/organization/Functions/Hierarchy/fn_get_ancestors.sql
-- PURPOSE: دالة الحصول على جميع الفروع الأب لفرع معين
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_get_ancestors(
    p_descendant_id INT,
    p_include_self BOOLEAN DEFAULT false
) RETURNS TABLE (
    branch_id INT,
    branch_code VARCHAR,
    branch_name_ar VARCHAR,
    depth INT,
    level INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.branch_id,
        b.branch_code,
        b.branch_name_ar,
        bc.depth,
        b.level
    FROM organization.branch_closure bc
    JOIN organization.branches b ON bc.ancestor = b.branch_id
    WHERE bc.descendant = p_descendant_id
      AND (p_include_self OR bc.depth > 0)
    ORDER BY bc.depth DESC;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION organization.fn_get_ancestors(INT, BOOLEAN) IS 'الحصول على جميع الفروع الأب';

-- رسالة تأكيد
SELECT '✅ Function fn_get_ancestors created successfully' AS status;