-- =============================================
-- FILE: structure/organization/Tables/operational_statuses.sql
-- PURPOSE: إنشاء جدول حالات التشغيل (Lookup)
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول حالات التشغيل
CREATE TABLE IF NOT EXISTS organization.operational_statuses (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(20) UNIQUE NOT NULL,
    status_name_ar VARCHAR(100) NOT NULL,
    status_name_en VARCHAR(100),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إضافة تعليقات
COMMENT ON TABLE organization.operational_statuses IS 'حالات التشغيل (بيانات ثابتة)';
COMMENT ON COLUMN organization.operational_statuses.status_id IS 'المعرف الفريد للحالة';
COMMENT ON COLUMN organization.operational_statuses.status_code IS 'كود الحالة (ready, active, standby, maintenance)';
COMMENT ON COLUMN organization.operational_statuses.status_name_ar IS 'اسم الحالة بالعربية';
COMMENT ON COLUMN organization.operational_statuses.status_name_en IS 'اسم الحالة بالإنجليزية';
COMMENT ON COLUMN organization.operational_statuses.sort_order IS 'ترتيب العرض';

-- رسالة تأكيد
SELECT '✅ Table operational_statuses created successfully' AS status;