 
-- =============================================
-- FILE: structure/assets/Tables/resources.sql
-- PURPOSE: إنشاء جدول الموارد (المواد الاستهلاكية)
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول الموارد
CREATE TABLE IF NOT EXISTS assets.resources (
    resource_id SERIAL PRIMARY KEY,
    resource_code VARCHAR(100) UNIQUE NOT NULL,
    resource_name_ar VARCHAR(255) NOT NULL,
    resource_name_en VARCHAR(255),
    type_id INT NOT NULL REFERENCES assets.resource_types(type_id) ON DELETE RESTRICT,
    unit VARCHAR(50),
    minimum_stock DECIMAL(10,2) DEFAULT 0,
    maximum_stock DECIMAL(10,2),
    current_stock DECIMAL(10,2) DEFAULT 0,
    reorder_level DECIMAL(10,2) DEFAULT 0,
    location VARCHAR(255),
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_stock_range CHECK (current_stock >= 0 AND (maximum_stock IS NULL OR current_stock <= maximum_stock)),
    CONSTRAINT chk_min_max CHECK (minimum_stock <= maximum_stock OR maximum_stock IS NULL),
    CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.resources IS 'جدول الموارد والمواد الاستهلاكية';
COMMENT ON COLUMN assets.resources.resource_id IS 'المعرف الفريد للمورد';
COMMENT ON COLUMN assets.resources.resource_code IS 'كود المورد الفريد';
COMMENT ON COLUMN assets.resources.unit IS 'وحدة القياس';
COMMENT ON COLUMN assets.resources.current_stock IS 'الكمية الحالية';
COMMENT ON COLUMN assets.resources.minimum_stock IS 'الحد الأدنى للمخزون';
COMMENT ON COLUMN assets.resources.maximum_stock IS 'الحد الأقصى للمخزون';

-- رسالة تأكيد
SELECT '✅ Table resources created successfully' AS status;