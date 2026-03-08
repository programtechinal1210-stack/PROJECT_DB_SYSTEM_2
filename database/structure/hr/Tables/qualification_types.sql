-- =============================================
-- FILE: structure/hr/Tables/qualification_types.sql
-- PURPOSE: إنشاء جدول أنواع المؤهلات
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع المؤهلات
CREATE TABLE IF NOT EXISTS hr.qualification_types (
    type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(100) NOT NULL,
    type_name_en VARCHAR(100),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إضافة تعليقات
COMMENT ON TABLE hr.qualification_types IS 'أنواع المؤهلات (بيانات ثابتة)';
COMMENT ON COLUMN hr.qualification_types.type_id IS 'المعرف الفريد لنوع المؤهل';
COMMENT ON COLUMN hr.qualification_types.type_code IS 'كود النوع';
COMMENT ON COLUMN hr.qualification_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN hr.qualification_types.type_name_en IS 'اسم النوع بالإنجليزية';

-- رسالة تأكيد
SELECT '✅ Table qualification_types created successfully' AS status;