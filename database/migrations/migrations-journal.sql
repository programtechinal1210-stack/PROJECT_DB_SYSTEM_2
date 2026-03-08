 
-- =============================================
-- FILE: migrations/migrations-journal.sql
-- PURPOSE: جدول تتبع المايجريشنز المنفذة
-- VERSION: 1.0.0
-- =============================================

\c project_db_system;

-- إنشاء جدول تتبع المايجريشنز إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS migrations.schema_migrations (
    migration_id SERIAL PRIMARY KEY,
    version VARCHAR(50) NOT NULL,
    migration_name VARCHAR(255) NOT NULL,
    script_name VARCHAR(255) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    applied_by VARCHAR(100) DEFAULT current_user,
    execution_time_ms INTEGER,
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    
    UNIQUE(version, migration_name)
);

-- إنشاء فهرس
CREATE INDEX IF NOT EXISTS idx_migrations_version 
    ON migrations.schema_migrations(version);

-- دالة لتسجيل المايجريشن
CREATE OR REPLACE FUNCTION migrations.log_migration(
    p_version VARCHAR,
    p_migration_name VARCHAR,
    p_script_name VARCHAR,
    p_execution_time_ms INTEGER,
    p_success BOOLEAN,
    p_error_message TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO migrations.schema_migrations (
        version, migration_name, script_name, execution_time_ms, success, error_message
    ) VALUES (
        p_version, p_migration_name, p_script_name, p_execution_time_ms, p_success, p_error_message
    );
END;
$$ LANGUAGE plpgsql;

-- دالة للتحقق من تنفيذ مايجريشن
CREATE OR REPLACE FUNCTION migrations.is_migration_applied(
    p_version VARCHAR,
    p_migration_name VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM migrations.schema_migrations
    WHERE version = p_version 
      AND migration_name = p_migration_name
      AND success = true;
    
    RETURN v_count > 0;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على آخر مايجريشن منفذ
CREATE OR REPLACE FUNCTION migrations.get_last_migration()
RETURNS TABLE (
    version VARCHAR,
    migration_name VARCHAR,
    applied_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT sm.version, sm.migration_name, sm.applied_at
    FROM migrations.schema_migrations sm
    WHERE sm.success = true
    ORDER BY sm.applied_at DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- رسالة تأكيد
SELECT '✅ Migrations journal created successfully' AS status;