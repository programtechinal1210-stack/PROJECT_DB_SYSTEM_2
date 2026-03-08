 
-- =============================================
-- FILE: seeds/03-hr/002-qualifications.sql
-- PURPOSE: إدراج المؤهلات
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج المؤهلات
INSERT INTO hr.qualifications (
    qualification_code,
    qualification_name_ar,
    qualification_name_en,
    qualification_type_id,
    description,
    is_active
) VALUES
-- مؤهلات تعليمية
('BSC-CS', 'بكالوريوس علوم حاسوب', 'Bachelor of Computer Science', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'bachelor'), 
 'بكالوريوس في علوم الحاسوب', true),
 
('BSC-IS', 'بكالوريوس نظم معلومات', 'Bachelor of Information Systems', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'bachelor'), 
 'بكالوريوس في نظم المعلومات', true),
 
('BSC-ACC', 'بكالوريوس محاسبة', 'Bachelor of Accounting', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'bachelor'), 
 'بكالوريوس في المحاسبة', true),
 
('BSC-MKT', 'بكالوريوس تسويق', 'Bachelor of Marketing', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'bachelor'), 
 'بكالوريوس في التسويق', true),
 
('BA-HR', 'بكالوريوس موارد بشرية', 'Bachelor of Human Resources', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'bachelor'), 
 'بكالوريوس في الموارد البشرية', true),
 
-- مؤهلات عليا
('MBA', 'ماجستير إدارة أعمال', 'Master of Business Administration', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'master'), 
 'ماجستير في إدارة الأعمال', true),
 
('MSC-CS', 'ماجستير علوم حاسوب', 'Master of Computer Science', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'master'), 
 'ماجستير في علوم الحاسوب', true),
 
('PHD-CS', 'دكتوراه علوم حاسوب', 'PhD in Computer Science', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'doctorate'), 
 'دكتوراه في علوم الحاسوب', true),

-- شهادات مهنية
('PMP', 'مدير مشاريع محترف', 'Project Management Professional', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'professional'), 
 'شهادة PMP في إدارة المشاريع', true),
 
('CMA', 'محاسب إداري معتمد', 'Certified Management Accountant', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'professional'), 
 'شهادة CMA في المحاسبة الإدارية', true),
 
('CIPD', 'دبلوم الموارد البشرية', 'CIPD Diploma', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'professional'), 
 'دبلوم CIPD في الموارد البشرية', true),
 
('ITIL', 'آي تيل', 'ITIL Foundation', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'certificate'), 
 'شهادة ITIL في إدارة خدمات تقنية المعلومات', true),

-- دورات تدريبية
('LEAN', 'لين سيكس سيغما', 'Lean Six Sigma', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'training'), 
 'دورة لين سيكس سيغما', true),
 
('LEADERSHIP', 'القيادة الإدارية', 'Leadership Skills', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'training'), 
 'دورة مهارات القيادة', true),

-- رخص
('DRIVING', 'رخصة قيادة', 'Driving License', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'license'), 
 'رخصة قيادة سارية المفعول', true),
 
('HEAVY', 'رخصة معدات ثقيلة', 'Heavy Equipment License', 
 (SELECT type_id FROM hr.qualification_types WHERE type_code = 'license'), 
 'رخصة قيادة معدات ثقيلة', true)
ON CONFLICT (qualification_code) DO UPDATE SET
    qualification_name_ar = EXCLUDED.qualification_name_ar,
    qualification_name_en = EXCLUDED.qualification_name_en,
    description = EXCLUDED.description;

-- عرض عدد المؤهلات
SELECT 
    '✅ Qualifications seeded' AS status,
    COUNT(*) AS total_qualifications
FROM hr.qualifications;