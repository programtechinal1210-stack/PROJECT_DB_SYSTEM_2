 
-- =============================================
-- FILE: structure/field/Tables/location_facilities.sql
-- PURPOSE: إنشاء جدول منشآت المواقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول منشآت المواقع
CREATE TABLE IF NOT EXISTS field.location_facilities (
    facility_id SERIAL PRIMARY KEY,
    facility_code VARCHAR(50) UNIQUE NOT NULL,
    facility_name_ar VARCHAR(255) NOT NULL,
    facility_name_en VARCHAR(255),
    
    -- الربط
    location_id INT NOT NULL REFERENCES field.locations(location_id) ON DELETE CASCADE,
    facility_type_id INT NOT NULL REFERENCES field.facility_types(facility_type_id) ON DELETE CASCADE,
    
    -- معلومات أساسية
    is_required BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'planned',
    installation_date DATE,
    capacity DECIMAL(15,3),
    condition_rating field.facility_condition DEFAULT 'good',
    
    -- موقع المنشأة داخل الموقع
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- معلومات إضافية
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_facility_status CHECK (status IN ('planned', 'under_construction', 'completed', 'inactive', 'maintenance', 'decommissioned')),
    CONSTRAINT chk_installation_date CHECK (installation_date IS NULL OR installation_date <= CURRENT_DATE)
);

-- إضافة تعليقات
COMMENT ON TABLE field.location_facilities IS 'منشآت المواقع';
COMMENT ON COLUMN field.location_facilities.facility_id IS 'المعرف الفريد للمنشأة';
COMMENT ON COLUMN field.location_facilities.facility_code IS 'كود المنشأة';
COMMENT ON COLUMN field.location_facilities.location_id IS 'الموقع المرتبط';
COMMENT ON COLUMN field.location_facilities.facility_type_id IS 'نوع المنشأة';
COMMENT ON COLUMN field.location_facilities.status IS 'حالة المنشأة';
COMMENT ON COLUMN field.location_facilities.condition_rating IS 'تقييم حالة المنشأة';

-- رسالة تأكيد
SELECT '✅ Table location_facilities created successfully' AS status;