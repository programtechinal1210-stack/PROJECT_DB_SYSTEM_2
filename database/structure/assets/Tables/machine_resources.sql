 
-- =============================================
-- FILE: structure/assets/Tables/machine_resources.sql
-- PURPOSE: إنشاء جدول ربط الآلات بالموارد
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول ربط الآلات بالموارد
CREATE TABLE IF NOT EXISTS assets.machine_resources (
    machine_resource_id SERIAL PRIMARY KEY,
    machine_id INT NOT NULL REFERENCES assets.machines(machine_id) ON DELETE CASCADE,
    resource_id INT NOT NULL REFERENCES assets.resources(resource_id) ON DELETE CASCADE,
    quantity DECIMAL(10,2) DEFAULT 0,
    required_quantity DECIMAL(10,2) DEFAULT 0,
    unit VARCHAR(50),
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(machine_id, resource_id),
    
    -- القيود
    CONSTRAINT chk_quantity_positive CHECK (quantity >= 0),
    CONSTRAINT chk_required_positive CHECK (required_quantity >= 0)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.machine_resources IS 'ربط الآلات بالموارد المطلوبة';
COMMENT ON COLUMN assets.machine_resources.machine_resource_id IS 'المعرف الفريد للربط';
COMMENT ON COLUMN assets.machine_resources.machine_id IS 'معرف الآلة';
COMMENT ON COLUMN assets.machine_resources.resource_id IS 'معرف المورد';
COMMENT ON COLUMN assets.machine_resources.quantity IS 'الكمية الحالية';
COMMENT ON COLUMN assets.machine_resources.required_quantity IS 'الكمية المطلوبة';

-- رسالة تأكيد
SELECT '✅ Table machine_resources created successfully' AS status;