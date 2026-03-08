 
-- =============================================
-- FILE: structure/field/Tables/exploration_materials.sql
-- PURPOSE: إنشاء جدول مواد الاستكشاف
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول مواد الاستكشاف
CREATE TABLE IF NOT EXISTS field.exploration_materials (
    material_id SERIAL PRIMARY KEY,
    material_type VARCHAR(50) NOT NULL,
    material_code VARCHAR(50) UNIQUE NOT NULL,
    material_name_ar VARCHAR(255) NOT NULL,
    material_name_en VARCHAR(255),
    specifications TEXT,
    quantity DECIMAL(10,2) DEFAULT 0,
    unit VARCHAR(50),
    
    -- الموقع
    branch_id INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
    location_id INT NOT NULL REFERENCES field.locations(location_id) ON DELETE CASCADE,
    
    -- إدارة المخزون
    reorder_level DECIMAL(10,2) DEFAULT 100,
    last_restock_date DATE,
    expiry_date DATE,
    
    -- معلومات إضافية
    supplier VARCHAR(255),
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_material_type CHECK (material_type IN ('drilling_equipment', 'chemicals', 'lab_tools', 'fuel', 'spare_parts', 'explosives', 'safety_equipment')),
    CONSTRAINT chk_quantity_positive CHECK (quantity >= 0),
    CONSTRAINT chk_reorder_positive CHECK (reorder_level >= 0),
    CONSTRAINT chk_expiry CHECK (expiry_date IS NULL OR expiry_date >= CURRENT_DATE)
);

-- إضافة تعليقات
COMMENT ON TABLE field.exploration_materials IS 'مواد الاستكشاف';
COMMENT ON COLUMN field.exploration_materials.material_id IS 'المعرف الفريد للمادة';
COMMENT ON COLUMN field.exploration_materials.material_type IS 'نوع المادة';
COMMENT ON COLUMN field.exploration_materials.material_code IS 'كود المادة';
COMMENT ON COLUMN field.exploration_materials.quantity IS 'الكمية المتوفرة';
COMMENT ON COLUMN field.exploration_materials.branch_id IS 'الفرع المسؤول';
COMMENT ON COLUMN field.exploration_materials.location_id IS 'الموقع الحالي';

-- رسالة تأكيد
SELECT '✅ Table exploration_materials created successfully' AS status;