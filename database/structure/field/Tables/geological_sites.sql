 
-- =============================================
-- FILE: structure/field/Tables/geological_sites.sql
-- PURPOSE: إنشاء جدول المواقع الجيولوجية
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول المواقع الجيولوجية
CREATE TABLE IF NOT EXISTS field.geological_sites (
    site_id SERIAL PRIMARY KEY,
    site_code VARCHAR(50) UNIQUE NOT NULL,
    site_name_ar VARCHAR(255) NOT NULL,
    site_name_en VARCHAR(255),
    
    -- الربط بالموقع الرئيسي
    location_id INT NOT NULL REFERENCES field.locations(location_id) ON DELETE CASCADE,
    
    -- معلومات جيولوجية
    area_size DECIMAL(10,2),
    geological_features TEXT,
    mineral_deposits TEXT,
    estimated_reserves DECIMAL(15,2),
    reserve_unit VARCHAR(50),
    
    -- حالة الاستكشاف
    exploration_status VARCHAR(20) DEFAULT 'studying',
    discovered_date DATE,
    estimated_value DECIMAL(15,2),
    
    -- معلومات إضافية
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_exploration_status CHECK (exploration_status IN ('studying', 'exploring', 'completed', 'abandoned')),
    CONSTRAINT chk_discovered_date CHECK (discovered_date <= CURRENT_DATE)
);

-- إضافة تعليقات
COMMENT ON TABLE field.geological_sites IS 'المواقع الجيولوجية';
COMMENT ON COLUMN field.geological_sites.site_id IS 'المعرف الفريد للموقع الجيولوجي';
COMMENT ON COLUMN field.geological_sites.site_code IS 'كود الموقع الجيولوجي';
COMMENT ON COLUMN field.geological_sites.location_id IS 'الموقع المرتبط';
COMMENT ON COLUMN field.geological_sites.geological_features IS 'الخصائص الجيولوجية';
COMMENT ON COLUMN field.geological_sites.mineral_deposits IS 'الرواسب المعدنية';

-- رسالة تأكيد
SELECT '✅ Table geological_sites created successfully' AS status;