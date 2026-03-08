-- =============================================
-- FILE: structure/assets/Tables/resource_types.sql
-- PURPOSE: إنشاء جدول أنواع الموارد
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع الموارد
CREATE TABLE IF NOT EXISTS assets.resource_types (
    type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(100) NOT NULL,
    type_name_en VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.resource_types IS 'أنواع الموارد';
COMMENT ON COLUMN assets.resource_types.type_id IS 'المعرف الفريد لنوع المورد';
COMMENT ON COLUMN assets.resource_types.type_code IS 'كود النوع';
COMMENT ON COLUMN assets.resource_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN assets.resource_types.type_name_en IS 'اسم النوع بالإنجليزية';

-- رسالة تأكيد
SELECT '✅ Table resource_types created successfully' AS status;