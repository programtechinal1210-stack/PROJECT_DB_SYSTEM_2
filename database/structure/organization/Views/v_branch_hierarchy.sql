 
-- =============================================
-- FILE: structure/organization/Views/v_branch_hierarchy.sql
-- PURPOSE: عرض التسلسل الهرمي للفروع
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW organization.v_branch_hierarchy AS
WITH RECURSIVE branch_tree AS (
    -- المستوى الأول (الفروع الرئيسية)
    SELECT 
        b.branch_id,
        b.branch_code,
        b.branch_name_ar,
        b.branch_name_en,
        b.parent_branch_id,
        b.level,
        bt.type_name_ar AS branch_type_name,
        os.status_name_ar AS status_name,
        1 AS tree_level,
        ARRAY[b.branch_name_ar] AS path_names,
        ARRAY[b.branch_id] AS path_ids
    FROM organization.branches b
    LEFT JOIN organization.branch_types bt ON b.branch_type_id = bt.type_id
    LEFT JOIN organization.operational_statuses os ON b.operational_status_id = os.status_id
    WHERE b.parent_branch_id IS NULL
    
    UNION ALL
    
    -- المستويات التالية
    SELECT 
        c.branch_id,
        c.branch_code,
        c.branch_name_ar,
        c.branch_name_en,
        c.parent_branch_id,
        c.level,
        bt.type_name_ar,
        os.status_name_ar,
        bt.tree_level + 1,
        bt.path_names || c.branch_name_ar,
        bt.path_ids || c.branch_id
    FROM organization.branches c
    INNER JOIN branch_tree bt ON c.parent_branch_id = bt.branch_id
    LEFT JOIN organization.branch_types bt ON c.branch_type_id = bt.type_id
    LEFT JOIN organization.operational_statuses os ON c.operational_status_id = os.status_id
)
SELECT 
    branch_id,
    branch_code,
    branch_name_ar,
    branch_name_en,
    parent_branch_id,
    level,
    branch_type_name,
    status_name,
    tree_level,
    array_to_string(path_names, ' → ') AS full_path,
    path_ids,
    (SELECT COUNT(*) FROM organization.branches WHERE parent_branch_id = bt.branch_id) AS children_count
FROM branch_tree bt
ORDER BY path_ids;

COMMENT ON VIEW organization.v_branch_hierarchy IS 'التسلسل الهرمي الكامل للفروع';

-- رسالة تأكيد
SELECT '✅ View v_branch_hierarchy created successfully' AS status;