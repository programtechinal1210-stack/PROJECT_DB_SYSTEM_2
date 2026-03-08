 
-- =============================================
-- FILE: structure/organization/Tables/sections.sql
-- PURPOSE: إنشاء جدول الأقسام
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول الأقسام
CREATE TABLE IF NOT EXISTS organization.sections (
    section_id SERIAL PRIMARY KEY,
    section_code VARCHAR(50) UNIQUE NOT NULL,
    section_name_ar VARCHAR(255) NOT NULL,
    section_name_en VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE organization.sections IS 'جدول الأقسام (بيانات ثابتة)';
COMMENT ON COLUMN organization.sections.section_id IS 'المعرف الفريد للقسم';
COMMENT ON COLUMN organization.sections.section_code IS 'كود القسم الفريد';
COMMENT ON COLUMN organization.sections.section_name_ar IS 'اسم القسم بالعربية';
COMMENT ON COLUMN organization.sections.section_name_en IS 'اسم القسم بالإنجليزية';
COMMENT ON COLUMN organization.sections.description IS 'وصف القسم';
COMMENT ON COLUMN organization.sections.is_active IS 'هل القسم نشط';

-- رسالة تأكيد
SELECT '✅ Table sections created successfully' AS status;