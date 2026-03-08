 
-- =============================================
-- FILE: structure/core/Tables/password_resets.sql
-- PURPOSE: إنشاء جدول إعادة تعيين كلمة المرور
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول إعادة تعيين كلمة المرور
CREATE TABLE IF NOT EXISTS core.password_resets (
    reset_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES core.users(user_id) ON DELETE CASCADE,
    reset_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- القيود
    CONSTRAINT chk_expiry_future CHECK (expires_at > created_at)
);

-- إضافة تعليقات
COMMENT ON TABLE core.password_resets IS 'طلبات إعادة تعيين كلمة المرور';
COMMENT ON COLUMN core.password_resets.reset_id IS 'المعرف الفريد للطلب';
COMMENT ON COLUMN core.password_resets.user_id IS 'معرف المستخدم';
COMMENT ON COLUMN core.password_resets.reset_token IS 'رمز إعادة التعيين';
COMMENT ON COLUMN core.password_resets.expires_at IS 'وقت انتهاء الصلاحية';
COMMENT ON COLUMN core.password_resets.used IS 'هل تم استخدام الرمز';
COMMENT ON COLUMN core.password_resets.used_at IS 'وقت الاستخدام';

-- رسالة تأكيد
SELECT '✅ Table password_resets created successfully' AS status;