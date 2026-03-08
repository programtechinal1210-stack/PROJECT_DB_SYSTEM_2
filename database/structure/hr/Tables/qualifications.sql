 
-- =============================================
-- FILE: structure/hr/Tables/qualifications.sql
-- PURPOSE: إنشاء جدول المؤهلات
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول المؤهلات
CREATE TABLE IF NOT EXISTS hr.qualifications (
    qualification_id SERIAL PRIMARY KEY,
    qualification_code VARCHAR(50) UNIQUE NOT NULL,
    qualification_name_ar VARCHAR(255) NOT NULL,
    qualification_name_en VARCHAR(255),
    qualification_type_id INT REFERENCES hr.qualification_types(type_id),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.qualifications IS 'جدول المؤهلات';
COMMENT ON COLUMN hr.qualifications.qualification_id IS 'المعرف الفريد للمؤهل';
COMMENT ON COLUMN hr.qualifications.qualification_code IS 'كود المؤهل الفريد';
COMMENT ON COLUMN hr.qualifications.qualification_name_ar IS 'اسم المؤهل بالعربية';
COMMENT ON COLUMN hr.qualifications.qualification_name_en IS 'اسم المؤهل بالإنجليزية';
COMMENT ON COLUMN hr.qualifications.qualification_type_id IS 'نوع المؤهل';
COMMENT ON COLUMN hr.qualifications.description IS 'وصف المؤهل';

-- رسالة تأكيد
SELECT '✅ Table qualifications created successfully' AS status;