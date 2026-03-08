 
-- =============================================
-- FILE: structure/core/Tables/user_sessions.sql
-- PURPOSE: إنشاء جدول جلسات المستخدمين
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول جلسات المستخدمين
CREATE TABLE IF NOT EXISTS core.user_sessions (
    session_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES core.users(user_id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    ip_address INET,
    user_agent TEXT,
    device_info JSONB DEFAULT '{}'::jsonb,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    -- القيود
    CONSTRAINT chk_expiry CHECK (expires_at > login_at)
);

-- إضافة تعليقات
COMMENT ON TABLE core.user_sessions IS 'جلسات المستخدمين';
COMMENT ON COLUMN core.user_sessions.session_id IS 'المعرف الفريد للجلسة';
COMMENT ON COLUMN core.user_sessions.user_id IS 'معرف المستخدم';
COMMENT ON COLUMN core.user_sessions.session_token IS 'رمز الجلسة';
COMMENT ON COLUMN core.user_sessions.refresh_token IS 'رمز التحديث';
COMMENT ON COLUMN core.user_sessions.ip_address IS 'عنوان IP';
COMMENT ON COLUMN core.user_sessions.user_agent IS 'متصفح المستخدم';
COMMENT ON COLUMN core.user_sessions.device_info IS 'معلومات الجهاز';
COMMENT ON COLUMN core.user_sessions.login_at IS 'وقت الدخول';
COMMENT ON COLUMN core.user_sessions.last_activity IS 'آخر نشاط';
COMMENT ON COLUMN core.user_sessions.expires_at IS 'وقت انتهاء الجلسة';
COMMENT ON COLUMN core.user_sessions.is_active IS 'هل الجلسة نشطة';

-- رسالة تأكيد
SELECT '✅ Table user_sessions created successfully' AS status;