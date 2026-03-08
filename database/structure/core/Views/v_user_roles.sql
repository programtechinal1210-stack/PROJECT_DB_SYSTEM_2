 
-- =============================================
-- FILE: structure/core/Views/v_user_roles.sql
-- PURPOSE: عرض أدوار المستخدمين
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW core.v_user_roles AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.user_status,
    r.role_id,
    r.role_code,
    r.role_name_ar,
    r.role_name_en,
    r.is_system_role,
    ur.assigned_at,
    ua.username AS assigned_by_username
FROM core.users u
JOIN core.user_roles ur ON u.user_id = ur.user_id
JOIN core.roles r ON ur.role_id = r.role_id
LEFT JOIN core.users ua ON ur.assigned_by = ua.user_id
WHERE u.user_status = 'active'
ORDER BY u.username, r.sort_order;

-- إضافة تعليق
COMMENT ON VIEW core.v_user_roles IS 'عرض أدوار المستخدمين';

-- رسالة تأكيد
SELECT '✅ View v_user_roles created successfully' AS status;