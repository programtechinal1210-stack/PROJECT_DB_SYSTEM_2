 
-- =============================================
-- FILE: structure/field/Tables/facility_properties.sql
-- PURPOSE: إنشاء جدول خصائص المنشآت
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول خصائص المنشآت
CREATE TABLE IF NOT EXISTS field.facility_properties (
    property_id SERIAL PRIMARY KEY,
    facility_type_id INT NOT NULL REFERENCES field.facility_types(facility_type_id) ON DELETE CASCADE,
    property_code VARCHAR(50) UNIQUE NOT NULL,
    property_name_ar VARCHAR(100) NOT NULL,
    property_name_en VARCHAR(100),
    property_type VARCHAR(20) DEFAULT 'text',
    property_unit VARCHAR(50),
    is_required BOOLEAN DEFAULT FALSE,
    min_value DECIMAL(15,3),
    max_value DECIMAL(15,3),
    possible_values JSONB,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- القيود
    CONSTRAINT chk_property_type CHECK (property_type IN ('numeric', 'text', 'date', 'boolean', 'list'))
);

-- إضافة تعليقات
COMMENT ON TABLE field.facility_properties IS 'خصائص المنشآت حسب النوع';
COMMENT ON COLUMN field.facility_properties.property_id IS 'المعرف الفريد للخاصية';
COMMENT ON COLUMN field.facility_properties.facility_type_id IS 'معرف نوع المنشأة';
COMMENT ON COLUMN field.facility_properties.property_code IS 'كود الخاصية';
COMMENT ON COLUMN field.facility_properties.property_type IS 'نوع الخاصية (numeric, text, date, boolean, list)';
COMMENT ON COLUMN field.facility_properties.possible_values IS 'القيم الممكنة (لنوع list)';

-- رسالة تأكيد
SELECT '✅ Table facility_properties created successfully' AS status;