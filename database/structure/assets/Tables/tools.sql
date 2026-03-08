 
-- =============================================
-- FILE: structure/assets/Tables/tools.sql
-- PURPOSE: إنشاء جدول الأدوات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول الأدوات
CREATE TABLE IF NOT EXISTS assets.tools (
    tool_id SERIAL PRIMARY KEY,
    tool_code VARCHAR(50) UNIQUE NOT NULL,
    tool_name_ar VARCHAR(255) NOT NULL,
    tool_name_en VARCHAR(255),
    serial_number VARCHAR(255) UNIQUE,
    category VARCHAR(100),
    manufacturer VARCHAR(255),
    model VARCHAR(100),
    purchase_date DATE,
    purchase_cost DECIMAL(12,2),
    current_value DECIMAL(12,2),
    warranty_expiry DATE,
    location_details VARCHAR(255),
    status assets.tool_status DEFAULT 'available',
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_purchase_date CHECK (purchase_date <= CURRENT_DATE),
    CONSTRAINT chk_warranty_expiry CHECK (warranty_expiry IS NULL OR warranty_expiry >= purchase_date)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.tools IS 'جدول الأدوات والمعدات الصغيرة';
COMMENT ON COLUMN assets.tools.tool_id IS 'المعرف الفريد للأداة';
COMMENT ON COLUMN assets.tools.tool_code IS 'كود الأداة الفريد';
COMMENT ON COLUMN assets.tools.serial_number IS 'الرقم التسلسلي';
COMMENT ON COLUMN assets.tools.status IS 'حالة الأداة';

-- رسالة تأكيد
SELECT '✅ Table tools created successfully' AS status;