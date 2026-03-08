 
-- =============================================
-- FILE: bootstrap/04-create-extensions.sql
-- PURPOSE: تفعيل الإضافات الضرورية
-- =============================================

\c project_db_system;

-- تفعيل الإضافات (CREATE EXTENSION IF NOT EXISTS)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";          -- UUID generator
CREATE EXTENSION IF NOT EXISTS "pgcrypto";           -- تشفير متقدم
CREATE EXTENSION IF NOT EXISTS "pg_trgm";            -- بحث نصي
CREATE EXTENSION IF NOT EXISTS "btree_gin";          -- فهارس مركبة
CREATE EXTENSION IF NOT EXISTS "postgis";            -- GIS للمواقع
CREATE EXTENSION IF NOT EXISTS "postgis_topology";   -- طوبولوجيا GIS
CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch";      -- مطابقة تقريبية
CREATE EXTENSION IF NOT EXISTS "unaccent";           -- إزالة التشكيل

-- رسالة تأكيد
SELECT '✅ All extensions enabled successfully' AS status;