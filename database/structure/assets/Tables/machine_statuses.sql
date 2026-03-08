-- =============================================
-- FILE: structure/assets/Tables/machine_statuses.sql
-- PURPOSE: إنشاء جدول حالات الآلات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول حالات الآلات
CREATE TABLE IF NOT EXISTS assets.machine_statuses (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) UNIQUE NOT NULL,
    status_name_ar VARCHAR(100) NOT NULL,
    status_name_en VARCHAR(100),
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إضافة تعليقات
COMMENT ON TABLE assets.machine_statuses IS 'حالات الآلات (بيانات ثابتة)';
COMMENT ON COLUMN assets.machine_statuses.status_id IS 'المعرف الفريد للحالة';
COMMENT ON COLUMN assets.machine_statuses.status_code IS 'كود الحالة';
COMMENT ON COLUMN assets.machine_statuses.status_name_ar IS 'اسم الحالة بالعربية';
COMMENT ON COLUMN assets.machine_statuses.status_name_en IS 'اسم الحالة بالإنجليزية';

-- رسالة تأكيد
SELECT '✅ Table machine_statuses created successfully' AS status;