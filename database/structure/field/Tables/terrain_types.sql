-- =============================================
-- FILE: structure/field/Tables/terrain_types.sql
-- PURPOSE: إنشاء جدول أنواع التضاريس
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع التضاريس
CREATE TABLE IF NOT EXISTS field.terrain_types (
    type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(100) NOT NULL,
    type_name_en VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إضافة تعليقات
COMMENT ON TABLE field.terrain_types IS 'أنواع التضاريس (بيانات ثابتة)';
COMMENT ON COLUMN field.terrain_types.type_id IS 'المعرف الفريد لنوع التضاريس';
COMMENT ON COLUMN field.terrain_types.type_code IS 'كود النوع';
COMMENT ON COLUMN field.terrain_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN field.terrain_types.type_name_en IS 'اسم النوع بالإنجليزية';

-- رسالة تأكيد
SELECT '✅ Table terrain_types created successfully' AS status;