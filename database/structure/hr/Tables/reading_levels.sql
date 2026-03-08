 
-- =============================================
-- FILE: structure/hr/Tables/reading_levels.sql
-- PURPOSE: إنشاء جدول مستويات القراءة
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول مستويات القراءة
CREATE TABLE IF NOT EXISTS hr.reading_levels (
    reading_level_id SERIAL PRIMARY KEY,
    level_code VARCHAR(20) UNIQUE NOT NULL,
    level_name_ar VARCHAR(255) NOT NULL,
    level_name_en VARCHAR(255),
    min_wpm INT, -- Words Per Minute (الحد الأدنى)
    max_wpm INT, -- Words Per Minute (الحد الأقصى)
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- القيود
    CONSTRAINT chk_wpm_range CHECK (min_wpm <= max_wpm),
    CONSTRAINT chk_wpm_positive CHECK (min_wpm >= 0 AND max_wpm >= 0)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.reading_levels IS 'مستويات القراءة';
COMMENT ON COLUMN hr.reading_levels.reading_level_id IS 'المعرف الفريد للمستوى';
COMMENT ON COLUMN hr.reading_levels.level_code IS 'كود المستوى';
COMMENT ON COLUMN hr.reading_levels.level_name_ar IS 'اسم المستوى بالعربية';
COMMENT ON COLUMN hr.reading_levels.level_name_en IS 'اسم المستوى بالإنجليزية';
COMMENT ON COLUMN hr.reading_levels.min_wpm IS 'الحد الأدنى لسرعة القراءة (كلمة/دقيقة)';
COMMENT ON COLUMN hr.reading_levels.max_wpm IS 'الحد الأقصى لسرعة القراءة (كلمة/دقيقة)';

-- رسالة تأكيد
SELECT '✅ Table reading_levels created successfully' AS status;