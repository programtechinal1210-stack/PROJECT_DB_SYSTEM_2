-- =============================================
-- FILE: structure/assets/Tables/machine_types.sql
-- PURPOSE: إنشاء جدول أنواع الآلات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع الآلات
CREATE TABLE IF NOT EXISTS assets.machine_types (
    type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) UNIQUE NOT NULL,
    type_name_ar VARCHAR(255) NOT NULL,
    type_name_en VARCHAR(255),
    description TEXT,
    parent_type_id INT REFERENCES assets.machine_types(type_id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.machine_types IS 'أنواع الآلات';
COMMENT ON COLUMN assets.machine_types.type_id IS 'المعرف الفريد لنوع الآلة';
COMMENT ON COLUMN assets.machine_types.type_code IS 'كود النوع';
COMMENT ON COLUMN assets.machine_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN assets.machine_types.type_name_en IS 'اسم النوع بالإنجليزية';

-- رسالة تأكيد
SELECT '✅ Table machine_types created successfully' AS status;