 
-- =============================================
-- FILE: structure/assets/Tables/device_type_required_equipments.sql
-- PURPOSE: إنشاء جدول المعدات المطلوبة لكل نوع جهاز
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول المعدات المطلوبة لأنواع الأجهزة
CREATE TABLE IF NOT EXISTS assets.device_type_required_equipments (
    id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES assets.device_types(type_id) ON DELETE CASCADE,
    equipment_code VARCHAR(50) UNIQUE NOT NULL,
    equipment_name_ar VARCHAR(100) NOT NULL,
    equipment_name_en VARCHAR(100),
    specs TEXT,
    is_required BOOLEAN DEFAULT true,
    quantity_required INT DEFAULT 1,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_quantity_positive CHECK (quantity_required > 0)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.device_type_required_equipments IS 'المعدات المطلوبة لكل نوع جهاز';
COMMENT ON COLUMN assets.device_type_required_equipments.id IS 'المعرف الفريد';
COMMENT ON COLUMN assets.device_type_required_equipments.type_id IS 'معرف نوع الجهاز';
COMMENT ON COLUMN assets.device_type_required_equipments.equipment_code IS 'كود المعدة';
COMMENT ON COLUMN assets.device_type_required_equipments.equipment_name_ar IS 'اسم المعدة بالعربية';
COMMENT ON COLUMN assets.device_type_required_equipments.is_required IS 'هل المعدة إلزامية';

-- رسالة تأكيد
SELECT '✅ Table device_type_required_equipments created successfully' AS status;