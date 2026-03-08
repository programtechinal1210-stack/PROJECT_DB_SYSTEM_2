-- =============================================
-- FILE: structure/organization/Views/v_branch_departments_full.sql
-- PURPOSE: عرض الإدارات والأقسام في كل فرع
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW organization.v_branch_departments_full AS
SELECT 
    b.branch_id,
    b.branch_code,
    b.branch_name_ar,
    d.department_id,
    d.department_code,
    d.department_name_ar,
    s.section_id,
    s.section_code,
    s.section_name_ar,
    bd.is_active AS department_active,
    bds.is_active AS section_active,
    bd.created_at AS department_assigned_at,
    bds.created_at AS section_assigned_at
FROM organization.branches b
LEFT JOIN organization.branch_departments bd ON b.branch_id = bd.branch_id
LEFT JOIN organization.departments d ON bd.department_id = d.department_id
LEFT JOIN organization.branch_dept_sections bds ON bd.branch_dept_id = bds.branch_dept_id
LEFT JOIN organization.sections s ON bds.section_id = s.section_id
ORDER BY b.branch_name_ar, d.department_name_ar, s.section_name_ar;

COMMENT ON VIEW organization.v_branch_departments_full IS 'عرض الإدارات والأقسام في كل فرع';

-- رسالة تأكيد
SELECT '✅ View v_branch_departments_full created successfully' AS status;