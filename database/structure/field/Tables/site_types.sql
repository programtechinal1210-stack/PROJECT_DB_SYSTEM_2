-- =============================================
-- FILE: structure/field/Tables/site_types.sql
-- PURPOSE: إنشاء جدول أنواع المواقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع المواقع
CREATE TABLE IF NOT EXISTS field.site_types (
    type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(100) NOT NULL,
    type_name_en VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE field.site_types IS 'أنواع المواقع (بيانات ثابتة)';
COMMENT ON COLUMN field.site_types.type_id IS 'المعرف الفريد لنوع الموقع';
COMMENT ON COLUMN field.site_types.type_code IS 'كود النوع';
COMMENT ON COLUMN field.site_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN field.site_types.type_name_en IS 'اسم النوع بالإنجليزية';

-- رسالة تأكيد
SELECT '✅ Table site_types created successfully' AS status;