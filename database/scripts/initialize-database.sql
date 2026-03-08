 
-- =============================================
-- FILE: scripts/initialize-database.sql
-- PURPOSE: تهيئة قاعدة البيانات بالكامل (bootstrap + migrations + seeds)
-- =============================================

\c project_db_system;

-- ============================================
-- 1. تشغيل ملفات bootstrap
-- ============================================
\echo '🚀 Running bootstrap files...'
\i '../bootstrap/01-create-database.sql'
\i '../bootstrap/02-create-schemas.sql'
\i '../bootstrap/03-create-roles.sql'
\i '../bootstrap/04-create-extensions.sql'

-- ============================================
-- 2. تشغيل ملفات الأمان
-- ============================================
\echo '🔐 Running security files...'
\i '../security/01-row-level-security.sql'
\i '../security/02-grants-permissions.sql'
\i '../security/03-encryption-keys.sql'
\i '../security/04-audit-triggers.sql'

-- ============================================
-- 3. تشغيل ملفات الـ migrations
-- ============================================
\echo '📋 Running migrations...'
\i '../migrations/migrations-journal.sql'
\i '../migrations/1.0.0/001-initial-core-tables.sql'
\i '../migrations/1.0.0/002-initial-organization-tables.sql'
\i '../migrations/1.0.0/003-initial-hr-tables.sql'
\i '../migrations/1.0.0/004-initial-assets-tables.sql'
\i '../migrations/1.0.0/005-initial-field-tables.sql'

-- ============================================
-- 4. تشغيل ملفات الـ structure
-- ============================================
\echo '🏗️ Running structure files...'

-- Core module
\i '../structure/core/Types/user_status.sql'
\i '../structure/core/Types/auth_provider.sql'
\i '../structure/core/Tables/users.sql'
\i '../structure/core/Tables/roles.sql'
\i '../structure/core/Tables/app_modules.sql'
\i '../structure/core/Tables/permissions.sql'
\i '../structure/core/Tables/user_roles.sql'
\i '../structure/core/Tables/role_permissions.sql'
\i '../structure/core/Tables/user_sessions.sql'
\i '../structure/core/Tables/login_attempts.sql'
\i '../structure/core/Tables/password_resets.sql'
\i '../structure/core/Tables/audit_log.sql'
\i '../structure/core/Tables/outbox_messages.sql'
\i '../structure/core/Tables/inbox_messages.sql'
\i '../structure/core/Indexes/core_indexes.sql'
\i '../structure/core/Views/v_user_permissions.sql'
\i '../structure/core/Views/v_user_roles.sql'
\i '../structure/core/Views/v_active_sessions.sql'
\i '../structure/core/Views/v_audit_log_summary.sql'
\i '../structure/core/Views/v_user_activity_summary.sql'

-- Organization module
\i '../structure/organization/Types/branch_type.sql'
\i '../structure/organization/Types/operational_status.sql'
\i '../structure/organization/Tables/branch_types.sql'
\i '../structure/organization/Tables/operational_statuses.sql'
\i '../structure/organization/Tables/branches.sql'
\i '../structure/organization/Tables/branch_closure.sql'
\i '../structure/organization/Tables/departments.sql'
\i '../structure/organization/Tables/sections.sql'
\i '../structure/organization/Tables/branch_departments.sql'
\i '../structure/organization/Tables/branch_dept_sections.sql'
\i '../structure/organization/Tables/outbox_messages.sql'
\i '../structure/organization/Tables/inbox_messages.sql'
\i '../structure/organization/Tables/audit_log.sql'
\i '../structure/organization/Indexes/organization_indexes.sql'

-- HR module
\i '../structure/hr/Types/attendance_status.sql'
\i '../structure/hr/Types/training_status.sql'
\i '../structure/hr/Types/employee_status.sql'
\i '../structure/hr/Types/qualification_type.sql'
\i '../structure/hr/Tables/qualification_types.sql'
\i '../structure/hr/Tables/qualifications.sql'
\i '../structure/hr/Tables/training_courses.sql'
\i '../structure/hr/Tables/reading_levels.sql'
\i '../structure/hr/Tables/job_levels.sql'
\i '../structure/hr/Tables/admin_specialties.sql'
\i '../structure/hr/Tables/employees.sql'
\i '../structure/hr/Tables/employee_assignments.sql'
\i '../structure/hr/Tables/employee_qualifications.sql'
\i '../structure/hr/Tables/employee_training.sql'
\i '../structure/hr/Tables/employee_specialties.sql'
\i '../structure/hr/Tables/employee_job_levels.sql'
\i '../structure/hr/Tables/employee_reading_levels.sql'
\i '../structure/hr/Tables/attendance.sql'
\i '../structure/hr/Tables/attendance_archive.sql'
\i '../structure/hr/Tables/outbox_messages.sql'
\i '../structure/hr/Tables/inbox_messages.sql'
\i '../structure/hr/Tables/audit_log.sql'
\i '../structure/hr/Indexes/hr_indexes.sql'

-- Assets module
\i '../structure/assets/Types/machine_status.sql'
\i '../structure/assets/Types/tool_status.sql'
\i '../structure/assets/Types/equipment_condition.sql'
\i '../structure/assets/Types/resource_type.sql'
\i '../structure/assets/Tables/machine_statuses.sql'
\i '../structure/assets/Tables/machine_types.sql'
\i '../structure/assets/Tables/resource_types.sql'
\i '../structure/assets/Tables/device_types.sql'
\i '../structure/assets/Tables/machines.sql'
\i '../structure/assets/Tables/tools.sql'
\i '../structure/assets/Tables/resources.sql'
\i '../structure/assets/Tables/machine_resources.sql'
\i '../structure/assets/Tables/machine_assignments.sql'
\i '../structure/assets/Tables/tool_assignments.sql'
\i '../structure/assets/Tables/objectives.sql'
\i '../structure/assets/Tables/machine_objectives.sql'
\i '../structure/assets/Tables/device_type_required_equipments.sql'
\i '../structure/assets/Tables/communication_devices.sql'
\i '../structure/assets/Tables/actual_device_equipments.sql'
\i '../structure/assets/Tables/maintenance_records.sql'
\i '../structure/assets/Tables/outbox_messages.sql'
\i '../structure/assets/Tables/inbox_messages.sql'
\i '../structure/assets/Tables/audit_log.sql'
\i '../structure/assets/Indexes/assets_indexes.sql'

-- Field module
\i '../structure/field/Types/site_type.sql'
\i '../structure/field/Types/terrain_type.sql'
\i '../structure/field/Types/exploration_phase.sql'
\i '../structure/field/Types/location_status.sql'
\i '../structure/field/Types/task_status.sql'
\i '../structure/field/Types/task_priority.sql'
\i '../structure/field/Types/facility_category.sql'
\i '../structure/field/Types/facility_condition.sql'
\i '../structure/field/Tables/site_types.sql'
\i '../structure/field/Tables/terrain_types.sql'
\i '../structure/field/Tables/exploration_phases.sql'
\i '../structure/field/Tables/facility_types.sql'
\i '../structure/field/Tables/facility_properties.sql'
\i '../structure/field/Tables/locations.sql'
\i '../structure/field/Tables/geological_sites.sql'
\i '../structure/field/Tables/exploration_materials.sql'
\i '../structure/field/Tables/location_facilities.sql'
\i '../structure/field/Tables/facility_property_values.sql'
\i '../structure/field/Tables/tasks.sql'
\i '../structure/field/Tables/task_assignments.sql'
\i '../structure/field/Tables/task_dependencies.sql'
\i '../structure/field/Tables/task_comments.sql'
\i '../structure/field/Tables/outbox_messages.sql'
\i '../structure/field/Tables/inbox_messages.sql'
\i '../structure/field/Tables/audit_log.sql'
\i '../structure/field/Indexes/field_indexes.sql'

-- ============================================
-- 5. تشغيل ملفات الـ audit
-- ============================================
\echo '📝 Running audit files...'
\i '../audit/01-create-audit-schema.sql'
\i '../audit/02-audit-tables.sql'
\i '../audit/03-audit-triggers.sql'
\i '../audit/04-audit-functions.sql'

-- ============================================
-- 6. تشغيل ملفات الـ seeds
-- ============================================
\echo '🌱 Running seed files...'

-- Core seeds
\i '../seeds/01-core/001-users.sql'
\i '../seeds/01-core/002-roles.sql'
\i '../seeds/01-core/003-app-modules.sql'
\i '../seeds/01-core/004-permissions.sql'
\i '../seeds/01-core/005-role-permissions.sql'
\i '../seeds/01-core/006-default-admin.sql'

-- Organization seeds
\i '../seeds/02-organization/001-departments.sql'
\i '../seeds/02-organization/002-sections.sql'
\i '../seeds/02-organization/003-branch-types.sql'
\i '../seeds/02-organization/004-operational-statuses.sql'
\i '../seeds/02-organization/005-branches.sql'

-- HR seeds
\i '../seeds/03-hr/001-qualification-types.sql'
\i '../seeds/03-hr/002-qualifications.sql'
\i '../seeds/03-hr/003-training-courses.sql'
\i '../seeds/03-hr/004-reading-levels.sql'
\i '../seeds/03-hr/005-job-levels.sql'
\i '../seeds/03-hr/006-admin-specialties.sql'

-- Assets seeds
\i '../seeds/04-assets/001-machine-statuses.sql'
\i '../seeds/04-assets/002-resource-types.sql'
\i '../seeds/04-assets/003-device-types.sql'

-- Field seeds
\i '../seeds/05-field/001-site-types.sql'
\i '../seeds/05-field/002-terrain-types.sql'
\i '../seeds/05-field/003-exploration-phases.sql'
\i '../seeds/05-field/004-facility-types.sql'
\i '../seeds/05-field/005-facility-properties.sql'

\echo '✅ Database initialization completed successfully!';

-- عرض ملخص
SELECT 
    (SELECT COUNT(*) FROM core.users) AS users_count,
    (SELECT COUNT(*) FROM core.roles) AS roles_count,
    (SELECT COUNT(*) FROM organization.branches) AS branches_count,
    (SELECT COUNT(*) FROM hr.employees) AS employees_count,
    (SELECT COUNT(*) FROM assets.machines) AS machines_count,
    (SELECT COUNT(*) FROM field.locations) AS locations_count;