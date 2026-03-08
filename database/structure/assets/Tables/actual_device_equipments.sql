 
-- =============================================
-- FILE: structure/assets/Tables/actual_device_equipments.sql
-- PURPOSE: إنشاء جدول المعدات الفعلية للأجهزة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول المعدات الفعلية للأجهزة
CREATE TABLE IF NOT EXISTS assets.actual_device_equipments (
    id SERIAL PRIMARY KEY,
    device_id INT NOT NULL REFERENCES assets.communication_devices(device_id) ON DELETE CASCADE,
    required_equip_id INT NOT NULL REFERENCES assets.device_type_required_equipments(id) ON DELETE CASCADE,
    serial_number VARCHAR(100),
    condition assets.equipment_condition DEFAULT 'good',
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(device_id, required_equip_id)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.actual_device_equipments IS 'المعدات الفعلية الموجودة مع كل جهاز';
COMMENT ON COLUMN assets.actual_device_equipments.id IS 'المعرف الفريد';
COMMENT ON COLUMN assets.actual_device_equipments.device_id IS 'معرف الجهاز';
COMMENT ON COLUMN assets.actual_device_equipments.required_equip_id IS 'معرف المعدة المطلوبة';
COMMENT ON COLUMN assets.actual_device_equipments.serial_number IS 'الرقم التسلسلي للمعدة';
COMMENT ON COLUMN assets.actual_device_equipments.condition IS 'حالة المعدة';

-- رسالة تأكيد
SELECT '✅ Table actual_device_equipments created successfully' AS status;