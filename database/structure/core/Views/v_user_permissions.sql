 
-- =============================================
-- FILE: structure/core/Views/v_user_permissions.sql
-- PURPOSE: عرض صلاحيات المستخدمين
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW core.v_user_permissions AS
SELECT DISTINCT
    u.user_id,
    u.username,
    u.email,
    p.permission_id,
    p.permission_code,
    p.permission_name_ar,
    p.action_type,
    m.module_code,
    m.module_name_ar,
    m.module_name_en
FROM core.users u
JOIN core.user_roles ur ON u.user_id = ur.user_id
JOIN core.role_permissions rp ON ur.role_id = rp.role_id
JOIN core.permissions p ON rp.permission_id = p.permission_id
JOIN core.app_modules m ON p.module_id = m.module_id
WHERE u.user_status = 'active'
  AND u.email_verified = true;

-- إضافة تعليق
COMMENT ON VIEW core.v_user_permissions IS 'عرض صلاحيات كل مستخدم (المستخدمين النشطين فقط)';

-- رسالة تأكيد
SELECT '✅ View v_user_permissions created successfully' AS status;