 
-- =============================================
-- FILE: migrations/1.0.0/001-initial-core-tables.sql
-- VERSION: 1.0.0
-- NAME: initial_core_tables
-- DESCRIPTION: إنشاء جداول المصادقة والصلاحيات الأساسية
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_execution_time_ms INTEGER;
    v_success BOOLEAN := true;
    v_error_message TEXT := NULL;
BEGIN
    -- بدء قياس الوقت
    v_start_time := clock_timestamp();
    
    -- التحقق من عدم تنفيذ المايجريشن مسبقاً
    IF migrations.is_migration_applied('1.0.0', 'initial_core_tables') THEN
        RAISE NOTICE 'Migration 1.0.0 - initial_core_tables already applied';
        RETURN;
    END IF;
    
    -- ============================================
    -- 1. إنشاء الأنواع المخصصة (ENUMs)
    -- ============================================
    
    -- حالة المستخدم
    DO $$ BEGIN
        CREATE TYPE core.user_status AS ENUM ('active', 'inactive', 'locked', 'pending');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- مزود المصادقة
    DO $$ BEGIN
        CREATE TYPE core.auth_provider AS ENUM ('local', 'google', 'microsoft', 'ldap');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- ============================================
    -- 2. إنشاء الجداول
    -- ============================================
    
    -- جدول المستخدمين
    CREATE TABLE IF NOT EXISTS core.users (
        user_id BIGSERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        user_status core.user_status DEFAULT 'pending',
        auth_provider core.auth_provider DEFAULT 'local',
        provider_id VARCHAR(255),
        email_verified BOOLEAN DEFAULT false,
        email_verified_at TIMESTAMP,
        last_login TIMESTAMP,
        last_login_ip INET,
        login_attempts INT DEFAULT 0,
        locked_until TIMESTAMP,
        employee_id INT,
        preferences JSONB DEFAULT '{}',
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        version INT DEFAULT 1,
        
        CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
        CONSTRAINT chk_username_length CHECK (char_length(username) >= 3)
    );

    -- جدول الأدوار
    CREATE TABLE IF NOT EXISTS core.roles (
        role_id SERIAL PRIMARY KEY,
        role_code VARCHAR(50) UNIQUE NOT NULL,
        role_name_ar VARCHAR(100) NOT NULL,
        role_name_en VARCHAR(100),
        role_description TEXT,
        is_system_role BOOLEAN DEFAULT false,
        sort_order INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id)
    );

    -- جدول وحدات التطبيق
    CREATE TABLE IF NOT EXISTS core.app_modules (
        module_id SERIAL PRIMARY KEY,
        module_code VARCHAR(50) UNIQUE NOT NULL,
        module_name_ar VARCHAR(100) NOT NULL,
        module_name_en VARCHAR(100),
        module_description TEXT,
        parent_module_id INT REFERENCES core.app_modules(module_id),
        module_level INT DEFAULT 1,
        display_order INT DEFAULT 0,
        icon VARCHAR(50),
        route VARCHAR(100),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id)
    );

    -- جدول الصلاحيات
    CREATE TABLE IF NOT EXISTS core.permissions (
        permission_id SERIAL PRIMARY KEY,
        permission_code VARCHAR(100) UNIQUE NOT NULL,
        permission_name_ar VARCHAR(100) NOT NULL,
        permission_name_en VARCHAR(100),
        permission_description TEXT,
        module_id INT NOT NULL REFERENCES core.app_modules(module_id),
        action_type VARCHAR(20) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_action_type CHECK (action_type IN ('create', 'read', 'update', 'delete', 'export', 'import', 'approve', 'reject'))
    );

    -- جدول أدوار المستخدمين
    CREATE TABLE IF NOT EXISTS core.user_roles (
        user_role_id BIGSERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL REFERENCES core.users(user_id) ON DELETE CASCADE,
        role_id INT NOT NULL REFERENCES core.roles(role_id) ON DELETE CASCADE,
        assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        assigned_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(user_id, role_id)
    );

    -- جدول صلاحيات الأدوار
    CREATE TABLE IF NOT EXISTS core.role_permissions (
        role_permission_id BIGSERIAL PRIMARY KEY,
        role_id INT NOT NULL REFERENCES core.roles(role_id) ON DELETE CASCADE,
        permission_id INT NOT NULL REFERENCES core.permissions(permission_id) ON DELETE CASCADE,
        granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        granted_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(role_id, permission_id)
    );

    -- جدول جلسات المستخدمين
    CREATE TABLE IF NOT EXISTS core.user_sessions (
        session_id BIGSERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL REFERENCES core.users(user_id) ON DELETE CASCADE,
        session_token VARCHAR(255) UNIQUE NOT NULL,
        refresh_token VARCHAR(255) UNIQUE,
        ip_address INET,
        user_agent TEXT,
        device_info JSONB,
        login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP NOT NULL,
        is_active BOOLEAN DEFAULT true,
        
        CONSTRAINT chk_expiry CHECK (expires_at > login_at)
    );

    -- جدول محاولات تسجيل الدخول
    CREATE TABLE IF NOT EXISTS core.login_attempts (
        attempt_id BIGSERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        ip_address INET,
        attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        success BOOLEAN DEFAULT false,
        failure_reason VARCHAR(100)
    );

    -- جدول إعادة تعيين كلمة المرور
    CREATE TABLE IF NOT EXISTS core.password_resets (
        reset_id BIGSERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL REFERENCES core.users(user_id) ON DELETE CASCADE,
        reset_token VARCHAR(255) UNIQUE NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        used BOOLEAN DEFAULT false,
        used_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        CONSTRAINT chk_expiry_future CHECK (expires_at > created_at)
    );

    -- جدول سجل التدقيق
    CREATE TABLE IF NOT EXISTS core.audit_log (
        audit_id BIGSERIAL PRIMARY KEY,
        table_name VARCHAR(100) NOT NULL,
        record_id BIGINT NOT NULL,
        operation VARCHAR(10) NOT NULL,
        old_data JSONB,
        new_data JSONB,
        changed_by VARCHAR(100),
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ip_address INET,
        user_agent TEXT,
        
        CONSTRAINT chk_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
    );

    -- جدول Outbox للرسائل (لـ Event-Driven Architecture)
    CREATE TABLE IF NOT EXISTS core.outbox_messages (
        outbox_id BIGSERIAL PRIMARY KEY,
        message_id UUID DEFAULT gen_random_uuid() UNIQUE,
        message_type VARCHAR(255) NOT NULL,
        aggregate_type VARCHAR(255) NOT NULL,
        aggregate_id BIGINT NOT NULL,
        payload JSONB NOT NULL,
        occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP,
        error TEXT,
        retry_count INT DEFAULT 0,
        status VARCHAR(20) DEFAULT 'pending',
        
        INDEX idx_outbox_status (status),
        INDEX idx_outbox_occurred (occurred_at)
    );

    -- جدول Inbox للرسائل
    CREATE TABLE IF NOT EXISTS core.inbox_messages (
        inbox_id BIGSERIAL PRIMARY KEY,
        message_id UUID UNIQUE NOT NULL,
        message_type VARCHAR(255) NOT NULL,
        payload JSONB NOT NULL,
        received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP,
        error TEXT,
        status VARCHAR(20) DEFAULT 'pending',
        
        INDEX idx_inbox_status (status),
        INDEX idx_inbox_message_id (message_id)
    );

    -- ============================================
    -- 3. إنشاء الفهارس
    -- ============================================
    CREATE INDEX IF NOT EXISTS idx_users_username ON core.users(username) WHERE user_status = 'active';
    CREATE INDEX IF NOT EXISTS idx_users_email ON core.users(email);
    CREATE INDEX IF NOT EXISTS idx_users_employee ON core.users(employee_id);
    CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON core.user_sessions(session_token);
    CREATE INDEX IF NOT EXISTS idx_user_sessions_refresh ON core.user_sessions(refresh_token);
    CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON core.user_sessions(user_id) WHERE is_active = true;
    CREATE INDEX IF NOT EXISTS idx_login_attempts_username_time ON core.login_attempts(username, attempt_time DESC);
    CREATE INDEX IF NOT EXISTS idx_audit_log_table_record ON core.audit_log(table_name, record_id);
    CREATE INDEX IF NOT EXISTS idx_audit_log_time ON core.audit_log(changed_at);
    CREATE INDEX IF NOT EXISTS idx_password_resets_token ON core.password_resets(reset_token);
    CREATE INDEX IF NOT EXISTS idx_password_resets_expiry ON core.password_resets(expires_at);

    -- ============================================
    -- 4. إنشاء الـ Triggers
    -- ============================================
    
    -- دالة تحديث updated_at
    CREATE OR REPLACE FUNCTION core.update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        NEW.version = OLD.version + 1;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger للمستخدمين
    DROP TRIGGER IF EXISTS update_users_updated_at ON core.users;
    CREATE TRIGGER update_users_updated_at 
        BEFORE UPDATE ON core.users 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- Trigger للأدوار
    DROP TRIGGER IF EXISTS update_roles_updated_at ON core.roles;
    CREATE TRIGGER update_roles_updated_at 
        BEFORE UPDATE ON core.roles 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- Trigger للصلاحيات
    DROP TRIGGER IF EXISTS update_permissions_updated_at ON core.permissions;
    CREATE TRIGGER update_permissions_updated_at 
        BEFORE UPDATE ON core.permissions 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- Trigger للوحدات
    DROP TRIGGER IF EXISTS update_modules_updated_at ON core.app_modules;
    CREATE TRIGGER update_modules_updated_at 
        BEFORE UPDATE ON core.app_modules 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- Trigger لتحديث آخر نشاط في الجلسة
    CREATE OR REPLACE FUNCTION core.update_session_activity()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.last_activity = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS update_session_activity ON core.user_sessions;
    CREATE TRIGGER update_session_activity 
        BEFORE UPDATE ON core.user_sessions 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_session_activity();

    -- ============================================
    -- 5. تسجيل المايجريشن
    -- ============================================
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_core_tables', 
        '001-initial-core-tables.sql', 
        v_execution_time_ms::INTEGER, 
        true
    );
    
    RAISE NOTICE 'Migration 1.0.0 - initial_core_tables completed successfully in % ms', v_execution_time_ms;
    
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_core_tables', 
        '001-initial-core-tables.sql', 
        v_execution_time_ms::INTEGER, 
        false, 
        v_error_message
    );
    RAISE;
END;
$$;

-- رسالة تأكيد نهائية
SELECT '✅ Core tables migration completed' AS migration_status;