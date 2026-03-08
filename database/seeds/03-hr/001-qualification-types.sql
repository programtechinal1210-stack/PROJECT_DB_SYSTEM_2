-- =============================================
-- FILE: seeds/03-hr/001-qualification-types.sql
-- PURPOSE: إدراج أنواع المؤهلات
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع المؤهلات
INSERT INTO hr.qualification_types (
    type_code, 
    type_name_ar, 
    type_name_en
) VALUES
('educational', 'تعليمي', 'Educational'),
('professional', 'مهني', 'Professional'),
('technical', 'تقني', 'Technical'),
('certificate', 'شهادة', 'Certificate'),
('diploma', 'دبلوم', 'Diploma'),
('bachelor', 'بكالوريوس', 'Bachelor'),
('master', 'ماجستير', 'Master'),
('doctorate', 'دكتوراه', 'Doctorate'),
('training', 'دورة تدريبية', 'Training Course'),
('license', 'رخصة', 'License')
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en;

-- عرض عدد أنواع المؤهلات
SELECT 
    '✅ Qualification types seeded' AS status,
    COUNT(*) AS total_types
FROM hr.qualification_types;