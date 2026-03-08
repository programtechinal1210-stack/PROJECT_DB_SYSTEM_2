 
-- =============================================
-- FILE: seeds/03-hr/005-job-levels.sql
-- PURPOSE: إدراج المستويات الوظيفية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج المستويات الوظيفية
INSERT INTO hr.job_levels (
    level_code,
    level_name_ar,
    level_name_en,
    description,
    sort_order
) VALUES
-- المستويات الوظيفية
('J1', 'مستوى أول', 'Level 1', 'موظف مبتدئ', 1),
('J2', 'مستوى ثاني', 'Level 2', 'موظف', 2),
('J3', 'مستوى ثالث', 'Level 3', 'موظف أول', 3),
('J4', 'مستوى رابع', 'Level 4', 'أخصائي', 4),

-- المستويات الإشرافية
('S1', 'مشرف', 'Supervisor', 'مشرف فريق', 5),
('S2', 'مشرف أول', 'Senior Supervisor', 'مشرف أول', 6),

-- المستويات الإدارية
('M1', 'مدير قسم', 'Department Manager', 'مدير قسم', 7),
('M2', 'مدير إدارة', 'Director', 'مدير إدارة', 8),
('M3', 'مدير عام', 'General Manager', 'مدير عام', 9),

-- المستويات التنفيذية
('E1', 'نائب رئيس', 'Vice President', 'نائب رئيس', 10),
('E2', 'رئيس تنفيذي', 'CEO', 'رئيس تنفيذي', 11)
ON CONFLICT (level_code) DO UPDATE SET
    level_name_ar = EXCLUDED.level_name_ar,
    level_name_en = EXCLUDED.level_name_en,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order;

-- عرض عدد المستويات
SELECT 
    '✅ Job levels seeded' AS status,
    COUNT(*) AS total_levels
FROM hr.job_levels;