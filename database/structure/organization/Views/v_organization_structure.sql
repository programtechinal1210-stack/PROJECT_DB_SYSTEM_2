 
-- =============================================
-- FILE: structure/organization/Views/v_organization_structure.sql
-- PURPOSE: عرض الهيكل التنظيمي الكامل
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW organization.v_organization_structure AS
-- الفروع
SELECT 
    b.branch_id AS entity_id,
    b.branch_code AS entity_code,
    b.branch_name_ar AS entity_name_ar,
    b.branch_name_en AS entity_name_en,
    'BRANCH' AS entity_type,
    b.parent_branch_id AS parent_id,
    NULL AS parent_entity_type,
    b.level,
    NULL::INT AS department_id,
    NULL::INT AS section_id,
    b.created_at
FROM organization.branches b
WHERE b.is_active = true

UNION ALL

-- الإدارات داخل الفروع
SELECT 
    bd.branch_dept_id,
    d.department_code,
    d.department_name_ar,
    d.department_name_en,
    'DEPARTMENT' AS entity_type,
    bd.branch_id AS parent_id,
    'BRANCH' AS parent_entity_type,
    b.level + 1,
    d.department_id,
    NULL,
    bd.created_at
FROM organization.branch_departments bd
JOIN organization.departments d ON bd.department_id = d.department_id
JOIN organization.branches b ON bd.branch_id = b.branch_id
WHERE bd.is_active = true AND d.is_active = true

UNION ALL

-- الأقسام داخل الإدارات
SELECT 
    bds.branch_dept_section_id,
    s.section_code,
    s.section_name_ar,
    s.section_name_en,
    'SECTION' AS entity_type,
    bds.branch_dept_id AS parent_id,
    'DEPARTMENT' AS parent_entity_type,
    b.level + 2,
    d.department_id,
    s.section_id,
    bds.created_at
FROM organization.branch_dept_sections bds
JOIN organization.sections s ON bds.section_id = s.section_id
JOIN organization.branch_departments bd ON bds.branch_dept_id = bd.branch_dept_id
JOIN organization.branches b ON bd.branch_id = b.branch_id
JOIN organization.departments d ON bd.department_id = d.department_id
WHERE bds.is_active = true AND s.is_active = true
ORDER BY level, entity_name_ar;

COMMENT ON VIEW organization.v_organization_structure IS 'الهيكل التنظيمي الكامل (فروع، إدارات، أقسام)';

-- رسالة تأكيد
SELECT '✅ View v_organization_structure created successfully' AS status;