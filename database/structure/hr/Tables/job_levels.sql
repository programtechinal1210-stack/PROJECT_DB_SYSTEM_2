 
-- =============================================
-- FILE: structure/hr/Tables/job_levels.sql
-- PURPOSE: إنشاء جدول المستويات الوظيفية
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول المستويات الوظيفية
CREATE TABLE IF NOT EXISTS hr.job_levels (
    level_id SERIAL PRIMARY KEY,
    level_code VARCHAR(50) UNIQUE NOT NULL,
    level_name_ar VARCHAR(255) NOT NULL,
    level_name_en VARCHAR(255),
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.job_levels IS 'المستويات الوظيفية';
COMMENT ON COLUMN hr.job_levels.level_id IS 'المعرف الفريد للمستوى';
COMMENT ON COLUMN hr.job_levels.level_code IS 'كود المستوى الوظيفي';
COMMENT ON COLUMN hr.job_levels.level_name_ar IS 'اسم المستوى بالعربية';
COMMENT ON COLUMN hr.job_levels.level_name_en IS 'اسم المستوى بالإنجليزية';
COMMENT ON COLUMN hr.job_levels.sort_order IS 'ترتيب العرض';

-- رسالة تأكيد
SELECT '✅ Table job_levels created successfully' AS status;