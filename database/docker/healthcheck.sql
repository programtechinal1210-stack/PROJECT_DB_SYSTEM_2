 
-- -- =============================================
-- -- FILE: docker/healthcheck.sql
-- -- PURPOSE: فحص صحة قاعدة البيانات
-- -- =============================================

-- -- التحقق من اتصال قاعدة البيانات
-- SELECT 1 AS connection_test;

-- -- التحقق من وجود PostGIS
-- SELECT postgis_version() AS postgis_version;

-- -- التحقق من وجود الـ schemas الأساسية
-- SELECT 
--     schema_name,
--     COUNT(*) OVER() AS total_schemas
-- FROM information_schema.schemata 
-- WHERE schema_name IN ('core', 'organization', 'hr', 'assets', 'field', 'audit');

-- -- التحقق من وجود الجداول الرئيسية
-- SELECT 
--     COUNT(*) AS core_tables_count
-- FROM information_schema.tables 
-- WHERE table_schema = 'core';

-- -- التحقق من أداء قاعدة البيانات
-- SELECT 
--     current_setting('max_connections') AS max_connections,
--     current_setting('shared_buffers') AS shared_buffers,
--     current_setting('work_mem') AS work_mem,
--     pg_database_size(current_database()) / 1024 / 1024 AS db_size_mb,
--     numbackends AS active_connections
-- FROM pg_stat_database 
-- WHERE datname = current_database();

-- -- التحقق من صحة الاتصال
-- SELECT 
--     '✅ Database is healthy' AS status,
--     current_database() AS database_name,
--     current_user AS user,
--     version() AS version;


-- =============================================
-- FILE: docker/healthcheck.sql
-- PURPOSE: فحص صحة قاعدة البيانات
-- =============================================

-- التحقق من اتصال قاعدة البيانات
SELECT 1 AS connection_test;

-- التحقق من وجود PostGIS
SELECT postgis_version() AS postgis_version;

-- التحقق من وجود الـ schemas الأساسية
SELECT 
    schema_name,
    COUNT(*) OVER() AS total_schemas
FROM information_schema.schemata 
WHERE schema_name IN ('core', 'organization', 'hr', 'assets', 'field', 'audit');

-- التحقق من وجود الجداول الرئيسية
SELECT 
    COUNT(*) AS core_tables_count
FROM information_schema.tables 
WHERE table_schema = 'core';

-- التحقق من أداء قاعدة البيانات
SELECT 
    current_setting('max_connections') AS max_connections,
    current_setting('shared_buffers') AS shared_buffers,
    current_setting('work_mem') AS work_mem,
    pg_database_size(current_database()) / 1024 / 1024 AS db_size_mb,
    numbackends AS active_connections
FROM pg_stat_database 
WHERE datname = current_database();

-- التحقق من صحة الاتصال
SELECT 
    '✅ Database is healthy' AS status,
    current_database() AS database_name,
    current_user AS user,
    version() AS version;