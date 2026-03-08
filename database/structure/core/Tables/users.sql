 
-- =============================================
-- FILE: structure/core/Tables/users.sql
-- PURPOSE: إنشاء جدول المستخدمين
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول المستخدمين
CREATE TABLE IF NOT EXISTS core.users (
    -- المعرفات الأساسية
    user_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    
    -- معلومات المصادقة
    password_hash VARCHAR(255) NOT NULL,
    user_status core.user_status DEFAULT 'pending',
    auth_provider core.auth_provider DEFAULT 'local',
    provider_id VARCHAR(255),
    
    -- التحقق من البريد الإلكتروني
    email_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMP,
    
    -- معلومات الجلسة
    last_login TIMESTAMP,
    last_login_ip INET,
    login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP,
    
    -- الربط مع جدول الموظفين
    employee_id INT, -- سيتم ربطه لاحقاً
    
    -- بيانات إضافية
    preferences JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- التحكم في التزامن
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_username_length CHECK (char_length(username) >= 3)
);

-- إضافة تعليقات على الجدول والأعمدة
COMMENT ON TABLE core.users IS 'جدول المستخدمين الأساسي';
COMMENT ON COLUMN core.users.user_id IS 'المعرف الفريد للمستخدم';
COMMENT ON COLUMN core.users.username IS 'اسم المستخدم للدخول';
COMMENT ON COLUMN core.users.email IS 'البريد الإلكتروني';
COMMENT ON COLUMN core.users.password_hash IS 'كلمة المرور مشفرة باستخدام bcrypt';
COMMENT ON COLUMN core.users.user_status IS 'حالة المستخدم';
COMMENT ON COLUMN core.users.auth_provider IS 'مزود المصادقة';
COMMENT ON COLUMN core.users.provider_id IS 'المعرف من مزود المصادقة الخارجي';
COMMENT ON COLUMN core.users.email_verified IS 'هل تم التحقق من البريد الإلكتروني';
COMMENT ON COLUMN core.users.last_login_ip IS 'آخر عنوان IP تم الدخول منه';
COMMENT ON COLUMN core.users.login_attempts IS 'عدد محاولات الدخول الفاشلة';
COMMENT ON COLUMN core.users.locked_until IS 'الوقت الذي ينتهي فيه قفل الحساب';
COMMENT ON COLUMN core.users.employee_id IS 'معرف الموظف المرتبط (من جدول hr.employees)';
COMMENT ON COLUMN core.users.preferences IS 'تفضيلات المستخدم بتنسيق JSON';
COMMENT ON COLUMN core.users.metadata IS 'بيانات إضافية عن المستخدم';
COMMENT ON COLUMN core.users.version IS 'رقم الإصدار للتحكم في التزامن';

-- رسالة تأكيد
SELECT '✅ Table users created successfully' AS status;