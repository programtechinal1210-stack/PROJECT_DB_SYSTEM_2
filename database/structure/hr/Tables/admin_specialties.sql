 
-- =============================================
-- FILE: structure/hr/Tables/admin_specialties.sql
-- PURPOSE: إنشاء جدول التخصصات الإدارية
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول التخصصات الإدارية
CREATE TABLE IF NOT EXISTS hr.admin_specialties (
    specialty_id SERIAL PRIMARY KEY,
    specialty_code VARCHAR(50) UNIQUE NOT NULL,
    specialty_name_ar VARCHAR(255) NOT NULL,
    specialty_name_en VARCHAR(255),
    field VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.admin_specialties IS 'التخصصات الإدارية';
COMMENT ON COLUMN hr.admin_specialties.specialty_id IS 'المعرف الفريد للتخصص';
COMMENT ON COLUMN hr.admin_specialties.specialty_code IS 'كود التخصص';
COMMENT ON COLUMN hr.admin_specialties.specialty_name_ar IS 'اسم التخصص بالعربية';
COMMENT ON COLUMN hr.admin_specialties.specialty_name_en IS 'اسم التخصص بالإنجليزية';
COMMENT ON COLUMN hr.admin_specialties.field IS 'المجال (تقنية، مالية، موارد بشرية...)';

-- رسالة تأكيد
SELECT '✅ Table admin_specialties created successfully' AS status;