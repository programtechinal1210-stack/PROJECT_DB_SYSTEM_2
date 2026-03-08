-- =============================================
-- FILE: seeds/05-field/003-exploration-phases.sql
-- PURPOSE: إدراج مراحل الاستكشاف
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج مراحل الاستكشاف
INSERT INTO field.exploration_phases (
    phase_code, 
    phase_name_ar, 
    phase_name_en
) VALUES
('initial', 'مسح أولي', 'Initial Survey'),
('exploratory', 'حفر استكشافي', 'Exploratory Drilling'),
('detailed', 'تقييم مفصل', 'Detailed Assessment'),
('production', 'إنتاج', 'Production'),
('reconnaissance', 'استطلاع', 'Reconnaissance'),
('geophysical', 'مسح جيوفيزيائي', 'Geophysical Survey'),
('geochemical', 'مسح جيوكيميائي', 'Geochemical Survey'),
('feasibility', 'دراسة جدوى', 'Feasibility Study'),
('development', 'تطوير', 'Development'),
('closure', 'إغلاق', 'Closure'),
('rehabilitation', 'تأهيل', 'Rehabilitation')
ON CONFLICT (phase_code) DO UPDATE SET
    phase_name_ar = EXCLUDED.phase_name_ar,
    phase_name_en = EXCLUDED.phase_name_en;

-- عرض عدد المراحل
SELECT 
    '✅ Exploration phases seeded' AS status,
    COUNT(*) AS total_phases
FROM field.exploration_phases;