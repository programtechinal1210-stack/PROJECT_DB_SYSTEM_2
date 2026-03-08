 
-- =============================================
-- FILE: structure/core/Tables/login_attempts.sql
-- PURPOSE: إنشاء جدول محاولات تسجيل الدخول
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول محاولات تسجيل الدخول
CREATE TABLE IF NOT EXISTS core.login_attempts (
    attempt_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    ip_address INET,
    attempt_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT false,
    failure_reason VARCHAR(100)
);

-- إضافة تعليقات
COMMENT ON TABLE core.login_attempts IS 'سجل محاولات تسجيل الدخول للأمان';
COMMENT ON COLUMN core.login_attempts.attempt_id IS 'المعرف الفريد للمحاولة';
COMMENT ON COLUMN core.login_attempts.username IS 'اسم المستخدم المحاول';
COMMENT ON COLUMN core.login_attempts.ip_address IS 'عنوان IP';
COMMENT ON COLUMN core.login_attempts.attempt_time IS 'وقت المحاولة';
COMMENT ON COLUMN core.login_attempts.success IS 'هل نجحت المحاولة';
COMMENT ON COLUMN core.login_attempts.failure_reason IS 'سبب الفشل';

-- رسالة تأكيد
SELECT '✅ Table login_attempts created successfully' AS status;