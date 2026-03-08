 
-- =============================================
-- FILE: seeds/01-core/006-default-admin.sql
-- PURPOSE: تعيين الأدوار للمستخدمين الافتراضيين
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- تعيين دور Admin للمستخدم admin
INSERT INTO core.user_roles (user_id, role_id, assigned_at)
SELECT u.user_id, r.role_id, CURRENT_TIMESTAMP
FROM core.users u, core.roles r
WHERE u.username = 'admin' AND r.role_code = 'ADMIN'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- تعيين دور HR للمستخدم hr_manager
INSERT INTO core.user_roles (user_id, role_id, assigned_at)
SELECT u.user_id, r.role_id, CURRENT_TIMESTAMP
FROM core.users u, core.roles r
WHERE u.username = 'hr_manager' AND r.role_code = 'HR_MANAGER'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- تعيين دور Viewer للمستخدم viewer
INSERT INTO core.user_roles (user_id, role_id, assigned_at)
SELECT u.user_id, r.role_id, CURRENT_TIMESTAMP
FROM core.users u, core.roles r
WHERE u.username = 'viewer' AND r.role_code = 'VIEWER'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- تعيين دور Data Entry للمستخدم data_entry
INSERT INTO core.user_roles (user_id, role_id, assigned_at)
SELECT u.user_id, r.role_id, CURRENT_TIMESTAMP
FROM core.users u, core.roles r
WHERE u.username = 'data_entry' AND r.role_code = 'DATA_ENTRY'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- تعيين دور Branch Manager للمستخدم branch_manager
INSERT INTO core.user_roles (user_id, role_id, assigned_at)
SELECT u.user_id, r.role_id, CURRENT_TIMESTAMP
FROM core.users u, core.roles r
WHERE u.username = 'branch_manager' AND r.role_code = 'BRANCH_MANAGER'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- عرض عدد التعيينات
SELECT 
    '✅ User roles assigned' AS status,
    COUNT(*) AS total_assignments
FROM core.user_roles;