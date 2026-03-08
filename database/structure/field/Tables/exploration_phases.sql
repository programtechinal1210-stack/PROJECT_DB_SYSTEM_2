-- =============================================
-- FILE: structure/field/Tables/exploration_phases.sql
-- PURPOSE: إنشاء جدول مراحل الاستكشاف
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول مراحل الاستكشاف
CREATE TABLE IF NOT EXISTS field.exploration_phases (
    phase_id SERIAL PRIMARY KEY,
    phase_code VARCHAR(50) UNIQUE NOT NULL,
    phase_name_ar VARCHAR(100) NOT NULL,
    phase_name_en VARCHAR(100),
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إضافة تعليقات
COMMENT ON TABLE field.exploration_phases IS 'مراحل الاستكشاف (بيانات ثابتة)';
COMMENT ON COLUMN field.exploration_phases.phase_id IS 'المعرف الفريد للمرحلة';
COMMENT ON COLUMN field.exploration_phases.phase_code IS 'كود المرحلة';
COMMENT ON COLUMN field.exploration_phases.phase_name_ar IS 'اسم المرحلة بالعربية';
COMMENT ON COLUMN field.exploration_phases.phase_name_en IS 'اسم المرحلة بالإنجليزية';
COMMENT ON COLUMN field.exploration_phases.sort_order IS 'ترتيب المرحلة';

-- رسالة تأكيد
SELECT '✅ Table exploration_phases created successfully' AS status;