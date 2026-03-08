 
 -- =============================================
-- FILE: scripts/clear-database.sql
-- PURPOSE: تنظيف قاعدة البيانات بشكل آمن مع مراعاة RLS
-- =============================================

\c project_db_system;

-- تعطيل التقييدات مؤقتاً
SET session_replication_role = 'replica';

-- تعطيل RLS مؤقتاً (للمسؤول فقط)
ALTER TABLE core.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE core.user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE core.role_permissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE hr.employees DISABLE ROW LEVEL SECURITY;
ALTER TABLE hr.attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE organization.branches DISABLE ROW LEVEL SECURITY;
ALTER TABLE assets.machines DISABLE ROW LEVEL SECURITY;
ALTER TABLE assets.tools DISABLE ROW LEVEL SECURITY;
ALTER TABLE field.locations DISABLE ROW LEVEL SECURITY;

-- حذف البيانات من الجداول بالترتيب العكسي للعلاقات
TRUNCATE TABLE audit.audit_log CASCADE;
TRUNCATE TABLE core.outbox_messages CASCADE;
TRUNCATE TABLE core.inbox_messages CASCADE;
TRUNCATE TABLE core.user_sessions CASCADE;
TRUNCATE TABLE core.password_resets CASCADE;
TRUNCATE TABLE core.login_attempts CASCADE;
TRUNCATE TABLE core.user_roles CASCADE;
TRUNCATE TABLE core.role_permissions CASCADE;
TRUNCATE TABLE core.permissions CASCADE;
TRUNCATE TABLE core.app_modules CASCADE;
TRUNCATE TABLE core.roles CASCADE;
TRUNCATE TABLE core.users CASCADE;

TRUNCATE TABLE hr.employee_reading_levels CASCADE;
TRUNCATE TABLE hr.employee_job_levels CASCADE;
TRUNCATE TABLE hr.employee_specialties CASCADE;
TRUNCATE TABLE hr.employee_training CASCADE;
TRUNCATE TABLE hr.employee_qualifications CASCADE;
TRUNCATE TABLE hr.employee_assignments CASCADE;
TRUNCATE TABLE hr.attendance CASCADE;
TRUNCATE TABLE hr.attendance_archive CASCADE;
TRUNCATE TABLE hr.employees CASCADE;
TRUNCATE TABLE hr.reading_levels CASCADE;
TRUNCATE TABLE hr.job_levels CASCADE;
TRUNCATE TABLE hr.admin_specialties CASCADE;
TRUNCATE TABLE hr.training_courses CASCADE;
TRUNCATE TABLE hr.qualifications CASCADE;
TRUNCATE TABLE hr.qualification_types CASCADE;

TRUNCATE TABLE organization.branch_dept_sections CASCADE;
TRUNCATE TABLE organization.branch_departments CASCADE;
TRUNCATE TABLE organization.branch_closure CASCADE;
TRUNCATE TABLE organization.branches CASCADE;
TRUNCATE TABLE organization.sections CASCADE;
TRUNCATE TABLE organization.departments CASCADE;
TRUNCATE TABLE organization.branch_types CASCADE;
TRUNCATE TABLE organization.operational_statuses CASCADE;

TRUNCATE TABLE assets.actual_device_equipments CASCADE;
TRUNCATE TABLE assets.communication_devices CASCADE;
TRUNCATE TABLE assets.device_type_required_equipments CASCADE;
TRUNCATE TABLE assets.device_types CASCADE;
TRUNCATE TABLE assets.machine_objectives CASCADE;
TRUNCATE TABLE assets.objectives CASCADE;
TRUNCATE TABLE assets.machine_assignments CASCADE;
TRUNCATE TABLE assets.tool_assignments CASCADE;
TRUNCATE TABLE assets.machine_resources CASCADE;
TRUNCATE TABLE assets.resources CASCADE;
TRUNCATE TABLE assets.resource_types CASCADE;
TRUNCATE TABLE assets.tools CASCADE;
TRUNCATE TABLE assets.machines CASCADE;
TRUNCATE TABLE assets.machine_types CASCADE;
TRUNCATE TABLE assets.machine_statuses CASCADE;

TRUNCATE TABLE field.task_comments CASCADE;
TRUNCATE TABLE field.task_dependencies CASCADE;
TRUNCATE TABLE field.task_assignments CASCADE;
TRUNCATE TABLE field.tasks CASCADE;
TRUNCATE TABLE field.facility_property_values CASCADE;
TRUNCATE TABLE field.location_facilities CASCADE;
TRUNCATE TABLE field.facility_properties CASCADE;
TRUNCATE TABLE field.facility_types CASCADE;
TRUNCATE TABLE field.exploration_materials CASCADE;
TRUNCATE TABLE field.geological_sites CASCADE;
TRUNCATE TABLE field.locations CASCADE;
TRUNCATE TABLE field.site_types CASCADE;
TRUNCATE TABLE field.terrain_types CASCADE;
TRUNCATE TABLE field.exploration_phases CASCADE;

-- إعادة تفعيل RLS
ALTER TABLE core.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE hr.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE hr.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets.machines ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets.tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE field.locations ENABLE ROW LEVEL SECURITY;

-- إعادة تفعيل التقييدات
SET session_replication_role = 'origin';

-- رسالة تأكيد
SELECT '✅ Database cleared successfully' AS status;