 
-- =============================================
-- FILE: structure/organization/Tables/departments.sql
-- PURPOSE: إنشاء جدول الإدارات
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول الإدارات
CREATE TABLE IF NOT EXISTS organization.departments (
    department_id SERIAL PRIMARY KEY,
    department_code VARCHAR(50) UNIQUE NOT NULL,
    department_name_ar VARCHAR(255) NOT NULL,
    department_name_en VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE organization.departments IS 'جدول الإدارات (بيانات ثابتة)';
COMMENT ON COLUMN organization.departments.department_id IS 'المعرف الفريد للإدارة';
COMMENT ON COLUMN organization.departments.department_code IS 'كود الإدارة الفريد';
COMMENT ON COLUMN organization.departments.department_name_ar IS 'اسم الإدارة بالعربية';
COMMENT ON COLUMN organization.departments.department_name_en IS 'اسم الإدارة بالإنجليزية';
COMMENT ON COLUMN organization.departments.description IS 'وصف الإدارة';
COMMENT ON COLUMN organization.departments.is_active IS 'هل الإدارة نشطة';

-- رسالة تأكيد
SELECT '✅ Table departments created successfully' AS status;