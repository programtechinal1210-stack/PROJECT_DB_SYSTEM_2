 
-- =============================================
-- FILE: structure/field/Tables/locations.sql
-- PURPOSE: إنشاء جدول المواقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- تفعيل PostGIS إذا لم يكن مفعل
CREATE EXTENSION IF NOT EXISTS postgis;

-- إنشاء جدول المواقع
CREATE TABLE IF NOT EXISTS field.locations (
    location_id SERIAL PRIMARY KEY,
    location_code VARCHAR(50) UNIQUE NOT NULL,
    location_name_ar VARCHAR(255) NOT NULL,
    location_name_en VARCHAR(255),
    
    -- الأنواع
    site_type_id INT REFERENCES field.site_types(type_id),
    terrain_type_id INT REFERENCES field.terrain_types(type_id),
    exploration_phase_id INT REFERENCES field.exploration_phases(phase_id) DEFAULT 1,
    
    -- الربط بالهيكل التنظيمي
    branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    
    -- الإحداثيات الجغرافية (PostGIS)
    coordinates GEOMETRY(POINT, 4326),
    latitude DECIMAL(10,8) GENERATED ALWAYS AS (ST_Y(coordinates)) STORED,
    longitude DECIMAL(11,8) GENERATED ALWAYS AS (ST_X(coordinates)) STORED,
    
    -- معلومات جغرافية إضافية
    elevation DECIMAL(8,2), -- الارتفاع عن سطح البحر بالأمتار
    area_size DECIMAL(10,2), -- المساحة بالكيلومتر المربع
    capacity INT, -- السعة الاستيعابية
    
    -- معلومات الموقع
    address TEXT,
    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    
    -- حالة الموقع
    status field.location_status DEFAULT 'safe',
    mineral_potential VARCHAR(20) DEFAULT 'unknown',
    
    -- معلومات إضافية
    description TEXT,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_mineral_potential CHECK (mineral_potential IN ('low', 'medium', 'high', 'unknown')),
    CONSTRAINT chk_capacity_positive CHECK (capacity IS NULL OR capacity > 0),
    CONSTRAINT chk_elevation CHECK (elevation IS NULL OR elevation BETWEEN -500 AND 9000)
);

-- إضافة تعليقات
COMMENT ON TABLE field.locations IS 'جدول المواقع الميدانية';
COMMENT ON COLUMN field.locations.location_id IS 'المعرف الفريد للموقع';
COMMENT ON COLUMN field.locations.location_code IS 'كود الموقع الفريد';
COMMENT ON COLUMN field.locations.location_name_ar IS 'اسم الموقع بالعربية';
COMMENT ON COLUMN field.locations.coordinates IS 'الإحداثيات الجغرافية (نقطة)';
COMMENT ON COLUMN field.locations.latitude IS 'خط العرض (محسوب تلقائياً)';
COMMENT ON COLUMN field.locations.longitude IS 'خط الطول (محسوب تلقائياً)';
COMMENT ON COLUMN field.locations.status IS 'حالة الموقع';

-- إنشاء فهرس مكاني
CREATE INDEX IF NOT EXISTS idx_locations_coordinates ON field.locations USING GIST (coordinates);

-- رسالة تأكيد
SELECT '✅ Table locations created successfully' AS status;