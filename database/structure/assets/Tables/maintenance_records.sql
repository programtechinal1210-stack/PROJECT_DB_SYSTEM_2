-- =============================================
-- FILE: structure/assets/Tables/maintenance_records.sql
-- PURPOSE: إنشاء جدول سجلات الصيانة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول سجلات الصيانة
CREATE TABLE IF NOT EXISTS assets.maintenance_records (
    record_id SERIAL PRIMARY KEY,
    asset_type VARCHAR(20) NOT NULL, -- 'machine', 'tool', 'device'
    asset_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(50), -- 'preventive', 'corrective', 'emergency'
    description TEXT,
    cost DECIMAL(12,2),
    performed_by VARCHAR(255),
    next_maintenance_date DATE,
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_asset_type CHECK (asset_type IN ('machine', 'tool', 'device')),
    CONSTRAINT chk_maintenance_type CHECK (maintenance_type IN ('preventive', 'corrective', 'emergency')),
    CONSTRAINT chk_maintenance_date CHECK (maintenance_date <= CURRENT_DATE)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.maintenance_records IS 'سجلات الصيانة لجميع أنواع الأصول';
COMMENT ON COLUMN assets.maintenance_records.record_id IS 'المعرف الفريد لسجل الصيانة';
COMMENT ON COLUMN assets.maintenance_records.asset_type IS 'نوع الأصل (machine, tool, device)';
COMMENT ON COLUMN assets.maintenance_records.asset_id IS 'معرف الأصل';
COMMENT ON COLUMN assets.maintenance_records.maintenance_type IS 'نوع الصيانة';

-- رسالة تأكيد
SELECT '✅ Table maintenance_records created successfully' AS status;