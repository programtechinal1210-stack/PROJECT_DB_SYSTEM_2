 
-- =============================================
-- FILE: structure/field/Tables/facility_property_values.sql
-- PURPOSE: إنشاء جدول قيم خصائص المنشآت
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول قيم خصائص المنشآت
CREATE TABLE IF NOT EXISTS field.facility_property_values (
    value_id SERIAL PRIMARY KEY,
    facility_id INT NOT NULL REFERENCES field.location_facilities(facility_id) ON DELETE CASCADE,
    property_id INT NOT NULL REFERENCES field.facility_properties(property_id) ON DELETE CASCADE,
    
    -- القيم حسب النوع
    numeric_value DECIMAL(15,3),
    text_value TEXT,
    date_value DATE,
    boolean_value BOOLEAN,
    
    -- معلومات التحقق
    last_verified DATE,
    verified_by INT REFERENCES core.users(user_id),
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(facility_id, property_id),
    
    -- القيود
    CONSTRAINT chk_at_least_one_value CHECK (
        numeric_value IS NOT NULL OR
        text_value IS NOT NULL OR
        date_value IS NOT NULL OR
        boolean_value IS NOT NULL
    )
);

-- إضافة تعليقات
COMMENT ON TABLE field.facility_property_values IS 'قيم خصائص المنشآت';
COMMENT ON COLUMN field.facility_property_values.value_id IS 'المعرف الفريد للقيمة';
COMMENT ON COLUMN field.facility_property_values.facility_id IS 'معرف المنشأة';
COMMENT ON COLUMN field.facility_property_values.property_id IS 'معرف الخاصية';
COMMENT ON COLUMN field.facility_property_values.last_verified IS 'تاريخ آخر تحقق';

-- رسالة تأكيد
SELECT '✅ Table facility_property_values created successfully' AS status;