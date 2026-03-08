-- ============================================
-- MASTER SQL FILE - تنفيذ كل شيء تلقائياً
-- ============================================

\echo '========================================'
\echo '🚀 بدء التهيئة الشاملة'
\echo '========================================'

-- ============================================
-- 1. إنشاء جميع الأنواع (Types)
-- ============================================
\echo '📌 1. إنشاء أنواع Core...'
\i '/structure/core/Types/user_status.sql'
\i '/structure/core/Types/auth_provider.sql'

\echo '📌 2. إنشاء أنواع Organization...'
\i '/structure/organization/Types/branch_type.sql'
\i '/structure/organization/Types/operational_status.sql'

\echo '📌 3. إنشاء أنواع HR...'
\i '/structure/hr/Types/attendance_status.sql'
\i '/structure/hr/Types/training_status.sql'
\i '/structure/hr/Types/employee_status.sql'
\i '/structure/hr/Types/qualification_type.sql'

\echo '📌 4. إنشاء أنواع Assets...'
\i '/structure/assets/Types/machine_status.sql'
\i '/structure/assets/Types/tool_status.sql'
\i '/structure/assets/Types/equipment_condition.sql'
\i '/structure/assets/Types/resource_type.sql'

\echo '📌 5. إنشاء أنواع Field...'
\i '/structure/field/Types/site_type.sql'
\i '/structure/field/Types/terrain_type.sql'
\i '/structure/field/Types/exploration_phase.sql'
\i '/structure/field/Types/location_status.sql'
\i '/structure/field/Types/task_status.sql'
\i '/structure/field/Types/task_priority.sql'
\i '/structure/field/Types/facility_category.sql'
\i '/structure/field/Types/facility_condition.sql'

\echo '✅ تم إنشاء جميع الأنواع بنجاح'

-- ============================================
-- 2. إنشاء جداول Core
-- ============================================
\echo '📌 6. إنشاء جداول Core...'
\i '/structure/core/Tables/users.sql'
\i '/structure/core/Tables/roles.sql'
\i '/structure/core/Tables/app_modules.sql'
\i '/structure/core/Tables/permissions.sql'
\i '/structure/core/Tables/user_roles.sql'
\i '/structure/core/Tables/role_permissions.sql'
\i '/structure/core/Tables/user_sessions.sql'
\i '/structure/core/Tables/login_attempts.sql'
\i '/structure/core/Tables/password_resets.sql'
\i '/structure/core/Tables/audit_log.sql'
\i '/structure/core/Tables/outbox_messages.sql'
\i '/structure/core/Tables/inbox_messages.sql'

\echo '✅ تم إنشاء جداول Core بنجاح'

-- عرض النتيجة النهائية
\echo '========================================'
\echo '🎉 تم التنفيذ بنجاح'
\echo '========================================'

SELECT '✅ All types and core tables created' as final_status;
