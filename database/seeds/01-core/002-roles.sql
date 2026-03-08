 
-- =============================================
-- FILE: seeds/01-core/002-roles.sql
-- PURPOSE: إدراج الأدوار الأساسية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج الأدوار إذا لم تكن موجودة
INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'ADMIN', 
    'مدير النظام', 
    'System Administrator', 
    'مدير النظام - لديه جميع الصلاحيات', 
    true, 
    1
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'ADMIN');

INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'HR_MANAGER', 
    'مدير الموارد البشرية', 
    'HR Manager', 
    'مدير الموارد البشرية - يدير شؤون الموظفين', 
    false, 
    2
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'HR_MANAGER');

INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'BRANCH_MANAGER', 
    'مدير فرع', 
    'Branch Manager', 
    'مدير فرع - يدير فرعاً محدداً', 
    false, 
    3
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'BRANCH_MANAGER');

INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'EMPLOYEE', 
    'موظف', 
    'Employee', 
    'موظف عادي - صلاحيات محدودة', 
    false, 
    4
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'EMPLOYEE');

INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'VIEWER', 
    'مشاهد', 
    'Viewer', 
    'مشاهد - عرض فقط', 
    false, 
    5
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'VIEWER');

INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'DATA_ENTRY', 
    'مدخل بيانات', 
    'Data Entry', 
    'مدخل بيانات - إدخال وتحديث البيانات', 
    false, 
    6
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'DATA_ENTRY');

INSERT INTO core.roles (
    role_code, 
    role_name_ar, 
    role_name_en, 
    role_description, 
    is_system_role, 
    sort_order
)
SELECT 
    'SUPERVISOR', 
    'مشرف', 
    'Supervisor', 
    'مشرف - يشرف على فريق', 
    false, 
    7
WHERE NOT EXISTS (SELECT 1 FROM core.roles WHERE role_code = 'SUPERVISOR');

-- عرض عدد الأدوار
SELECT 
    '✅ Core roles seeded' AS status,
    COUNT(*) AS total_roles
FROM core.roles;