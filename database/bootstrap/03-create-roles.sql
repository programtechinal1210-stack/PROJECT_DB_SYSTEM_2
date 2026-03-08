 
-- =============================================
-- FILE: bootstrap/03-create-roles.sql
-- PURPOSE: إنشاء الأدوار والصلاحيات على مستوى قاعدة البيانات
-- =============================================

\c project_db_system;

-- أدوار التطبيق
DO $$
BEGIN
    -- مدير النظام
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_admin') THEN
        CREATE ROLE app_admin;
    END IF;
    
    -- مدخل بيانات
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_data_entry') THEN
        CREATE ROLE app_data_entry;
    END IF;
    
    -- مشرف
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_viewer') THEN
        CREATE ROLE app_viewer;
    END IF;
    
    -- خدمة الخلفية
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_service') THEN
        CREATE ROLE app_service;
    END IF;
END
$$;

-- منح الصلاحيات للأدوار
GRANT CONNECT ON DATABASE project_db_system TO app_admin, app_data_entry, app_viewer, app_service;

-- منح استخدام الـ schemas
GRANT USAGE ON SCHEMA core TO app_admin, app_data_entry, app_viewer, app_service;
GRANT USAGE ON SCHEMA organization TO app_admin, app_data_entry, app_viewer, app_service;
GRANT USAGE ON SCHEMA hr TO app_admin, app_data_entry, app_viewer, app_service;
GRANT USAGE ON SCHEMA assets TO app_admin, app_data_entry, app_viewer, app_service;
GRANT USAGE ON SCHEMA field TO app_admin, app_data_entry, app_viewer, app_service;

-- رسالة تأكيد
SELECT '✅ Database roles created successfully' AS status;