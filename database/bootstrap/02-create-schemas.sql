 
-- =============================================
-- FILE: bootstrap/02-create-schemas.sql
-- PURPOSE: إنشاء الـ schemas الخاصة بكل Module
-- =============================================

\c project_db_system;

-- إنشاء schemas مع تعيين المالك
CREATE SCHEMA IF NOT EXISTS core AUTHORIZATION project_user;
CREATE SCHEMA IF NOT EXISTS organization AUTHORIZATION project_user;
CREATE SCHEMA IF NOT EXISTS hr AUTHORIZATION project_user;
CREATE SCHEMA IF NOT EXISTS assets AUTHORIZATION project_user;
CREATE SCHEMA IF NOT EXISTS field AUTHORIZATION project_user;
CREATE SCHEMA IF NOT EXISTS audit AUTHORIZATION project_user;
CREATE SCHEMA IF NOT EXISTS migrations AUTHORIZATION project_user;

-- تعيين مسار البحث الافتراضي
ALTER DATABASE project_db_system SET search_path TO core, organization, hr, assets, field, audit, public;

-- رسالة تأكيد
SELECT '✅ All schemas created successfully' AS status;