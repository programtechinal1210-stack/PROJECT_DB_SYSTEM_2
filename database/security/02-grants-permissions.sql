 
-- =============================================
-- FILE: security/02-grants-permissions.sql
-- PURPOSE: منح الصلاحيات للأدوار
-- =============================================

\c project_db_system;

-- --------------------------------------------
-- صلاحيات مدير النظام (app_admin)
-- --------------------------------------------
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA core TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA organization TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA assets TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA field TO app_admin;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA core TO app_admin;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA organization TO app_admin;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA hr TO app_admin;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA assets TO app_admin;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA field TO app_admin;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA core TO app_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA organization TO app_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA hr TO app_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA assets TO app_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA field TO app_admin;

-- --------------------------------------------
-- صلاحيات مدخل البيانات (app_data_entry)
-- --------------------------------------------
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA hr TO app_data_entry;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA assets TO app_data_entry;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA field TO app_data_entry;
GRANT SELECT ON ALL TABLES IN SCHEMA core TO app_data_entry;
GRANT SELECT ON ALL TABLES IN SCHEMA organization TO app_data_entry;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA hr TO app_data_entry;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA assets TO app_data_entry;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA field TO app_data_entry;

-- --------------------------------------------
-- صلاحيات المشاهد (app_viewer)
-- --------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA core TO app_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA organization TO app_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA hr TO app_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA assets TO app_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA field TO app_viewer;

-- --------------------------------------------
-- صلاحيات الخدمة (app_service)
-- --------------------------------------------
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA core TO app_service;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA organization TO app_service;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA hr TO app_service;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA assets TO app_service;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA field TO app_service;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA core TO app_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA organization TO app_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA hr TO app_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA assets TO app_service;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA field TO app_service;

-- رسالة تأكيد
SELECT '✅ Permissions granted successfully' AS status;