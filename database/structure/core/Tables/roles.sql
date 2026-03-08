 
-- =============================================
-- FILE: structure/core/Tables/roles.sql
-- PURPOSE: إنشاء جدول الأدوار
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول الأدوار
CREATE TABLE IF NOT EXISTS core.roles (
    role_id SERIAL PRIMARY KEY,
    role_code VARCHAR(50) UNIQUE NOT NULL,
    role_name_ar VARCHAR(100) NOT NULL,
    role_name_en VARCHAR(100),
    role_description TEXT,
    is_system_role BOOLEAN DEFAULT false,
    sort_order INT DEFAULT 0,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE core.roles IS 'جدول أدوار المستخدمين';
COMMENT ON COLUMN core.roles.role_id IS 'المعرف الفريد للدور';
COMMENT ON COLUMN core.roles.role_code IS 'كود الدور (مثل ADMIN, HR_MANAGER)';
COMMENT ON COLUMN core.roles.role_name_ar IS 'اسم الدور بالعربية';
COMMENT ON COLUMN core.roles.role_name_en IS 'اسم الدور بالإنجليزية';
COMMENT ON COLUMN core.roles.role_description IS 'وصف الدور';
COMMENT ON COLUMN core.roles.is_system_role IS 'دور نظامي لا يمكن حذفه';
COMMENT ON COLUMN core.roles.sort_order IS 'ترتيب العرض';

-- رسالة تأكيد
SELECT '✅ Table roles created successfully' AS status;