 -- =============================================
-- FILE: bootstrap/01-create-database.sql
-- PURPOSE: إنشاء قاعدة البيانات الرئيسية
-- =============================================

-- إنشاء قاعدة البيانات إذا لم تكن موجودة
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'project_db_system') THEN
        CREATE DATABASE project_db_system
            ENCODING 'UTF8'
            LC_COLLATE 'ar_SA.UTF-8'
            LC_CTYPE 'ar_SA.UTF-8'
            TEMPLATE template0;
    END IF;
END
$$;

-- الاتصال بقاعدة البيانات
\c project_db_system;

-- إنشاء المستخدم إذا لم يكن موجوداً
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'project_user') THEN
        CREATE USER project_user WITH PASSWORD 'Project@123456';
    END IF;
END
$$;

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON DATABASE project_db_system TO project_user;

-- رسالة تأكيد
SELECT '✅ Database created successfully' AS status;