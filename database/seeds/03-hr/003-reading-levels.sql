 
-- =============================================
-- FILE: seeds/03-hr/004-reading-levels.sql
-- PURPOSE: إدراج مستويات القراءة
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج مستويات القراءة
INSERT INTO hr.reading_levels (
    level_code,
    level_name_ar,
    level_name_en,
    min_wpm,
    max_wpm,
    description
) VALUES
('beginner', 'مبتدئ', 'Beginner', 0, 50, 'يقرأ ببطء ويحتاج إلى مساعدة'),
('intermediate', 'متوسط', 'Intermediate', 51, 100, 'يقرأ بسرعة متوسطة ويفهم النصوص البسيطة'),
('advanced', 'متقدم', 'Advanced', 101, 150, 'يقرأ بسرعة جيدة ويفهم النصوص المعقدة'),
('expert', 'خبير', 'Expert', 151, 999, 'يقرأ بسرعة عالية ويفهم النصوص المتخصصة')
ON CONFLICT (level_code) DO UPDATE SET
    level_name_ar = EXCLUDED.level_name_ar,
    level_name_en = EXCLUDED.level_name_en,
    min_wpm = EXCLUDED.min_wpm,
    max_wpm = EXCLUDED.max_wpm,
    description = EXCLUDED.description;

-- عرض عدد المستويات
SELECT 
    '✅ Reading levels seeded' AS status,
    COUNT(*) AS total_levels
FROM hr.reading_levels;