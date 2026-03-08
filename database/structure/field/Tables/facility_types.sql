 
-- =============================================
-- FILE: structure/field/Tables/facility_types.sql
-- PURPOSE: إنشاء جدول أنواع المنشآت
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع المنشآت
CREATE TABLE IF NOT EXISTS field.facility_types (
    facility_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(100) NOT NULL,
    type_name_en VARCHAR(100),
    type_category field.facility_category DEFAULT 'other',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE field.facility_types IS 'أنواع المنشآت';
COMMENT ON COLUMN field.facility_types.facility_type_id IS 'المعرف الفريد لنوع المنشأة';
COMMENT ON COLUMN field.facility_types.type_code IS 'كود النوع';
COMMENT ON COLUMN field.facility_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN field.facility_types.type_name_en IS 'اسم النوع بالإنجليزية';
COMMENT ON COLUMN field.facility_types.type_category IS 'فئة المنشأة';

-- رسالة تأكيد
SELECT '✅ Table facility_types created successfully' AS status;