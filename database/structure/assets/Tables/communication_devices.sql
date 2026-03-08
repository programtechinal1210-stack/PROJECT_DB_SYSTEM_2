 
-- =============================================
-- FILE: structure/assets/Tables/communication_devices.sql
-- PURPOSE: إنشاء جدول أجهزة الاتصال
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول أجهزة الاتصال
CREATE TABLE IF NOT EXISTS assets.communication_devices (
    device_id SERIAL PRIMARY KEY,
    device_code VARCHAR(50) UNIQUE NOT NULL,
    device_name_ar VARCHAR(255) NOT NULL,
    device_name_en VARCHAR(255),
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    type_id INT NOT NULL REFERENCES assets.device_types(type_id),
    
    -- التكليف الحالي
    machine_id INT REFERENCES assets.machines(machine_id) ON DELETE SET NULL,
    employee_id INT REFERENCES hr.employees(employee_id) ON DELETE SET NULL,
    
    -- الحالة
    status VARCHAR(20) DEFAULT 'active',
    condition assets.equipment_condition DEFAULT 'good',
    
    -- معلومات إضافية
    purchase_date DATE,
    warranty_expiry DATE,
    last_maintenance_date DATE,
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_device_status CHECK (status IN ('active', 'inactive', 'maintenance', 'lost')),
    CONSTRAINT chk_device_assignment CHECK (
        (machine_id IS NOT NULL AND employee_id IS NULL) OR
        (machine_id IS NULL AND employee_id IS NOT NULL) OR
        (machine_id IS NULL AND employee_id IS NULL)
    )
);

-- إضافة تعليقات
COMMENT ON TABLE assets.communication_devices IS 'أجهزة الاتصال (لاسلكي، أقمار صناعية، الخ)';
COMMENT ON COLUMN assets.communication_devices.device_id IS 'المعرف الفريد للجهاز';
COMMENT ON COLUMN assets.communication_devices.device_code IS 'كود الجهاز';
COMMENT ON COLUMN assets.communication_devices.serial_number IS 'الرقم التسلسلي';
COMMENT ON COLUMN assets.communication_devices.machine_id IS 'الآلة المرتبطة بها';
COMMENT ON COLUMN assets.communication_devices.employee_id IS 'الموظف المرتبط به';

-- رسالة تأكيد
SELECT '✅ Table communication_devices created successfully' AS status;