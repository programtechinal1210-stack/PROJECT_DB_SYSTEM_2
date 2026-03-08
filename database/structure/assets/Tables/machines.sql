 
-- =============================================
-- FILE: structure/assets/Tables/machines.sql
-- PURPOSE: إنشاء جدول الآلات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول الآلات
CREATE TABLE IF NOT EXISTS assets.machines (
    machine_id SERIAL PRIMARY KEY,
    machine_code VARCHAR(50) UNIQUE NOT NULL,
    machine_name_ar VARCHAR(255) NOT NULL,
    machine_name_en VARCHAR(255),
    machine_type_id INT REFERENCES assets.machine_types(type_id),
    serial_number VARCHAR(255) UNIQUE,
    model VARCHAR(100),
    manufacturer VARCHAR(255),
    manufacture_year INT,
    acquisition_date DATE,
    acquisition_cost DECIMAL(15,2),
    current_value DECIMAL(15,2),
    
    -- الصيانة
    maintenance_interval INT, -- بالأيام
    last_maintenance_date DATE,
    next_maintenance_date DATE GENERATED ALWAYS AS (last_maintenance_date + (maintenance_interval || ' days')::interval) STORED,
    
    -- التشغيل
    required_employees INT NOT NULL DEFAULT 1,
    minimum_presence INT NOT NULL DEFAULT 1,
    
    -- الحالة والموقع
    status_id INT REFERENCES assets.machine_statuses(status_id) DEFAULT 1,
    current_branch_id INT REFERENCES organization.branches(branch_id),
    current_branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id),
    current_branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id),
    
    -- معلومات إضافية
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_manufacture_year CHECK (manufacture_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE) + 5),
    CONSTRAINT chk_acquisition_date CHECK (acquisition_date <= CURRENT_DATE),
    CONSTRAINT chk_maintenance_interval CHECK (maintenance_interval > 0)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.machines IS 'جدول الآلات والمعدات الثقيلة';
COMMENT ON COLUMN assets.machines.machine_id IS 'المعرف الفريد للآلة';
COMMENT ON COLUMN assets.machines.machine_code IS 'كود الآلة الفريد';
COMMENT ON COLUMN assets.machines.serial_number IS 'الرقم التسلسلي';
COMMENT ON COLUMN assets.machines.maintenance_interval IS 'فترة الصيانة بالأيام';
COMMENT ON COLUMN assets.machines.next_maintenance_date IS 'تاريخ الصيانة القادم';

-- رسالة تأكيد
SELECT '✅ Table machines created successfully' AS status;