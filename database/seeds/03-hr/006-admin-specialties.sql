-- =============================================
-- FILE: seeds/03-hr/006-admin-specialties.sql
-- PURPOSE: إدراج التخصصات الإدارية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج التخصصات الإدارية
INSERT INTO hr.admin_specialties (
    specialty_code,
    specialty_name_ar,
    specialty_name_en,
    field,
    description
) VALUES
-- تخصصات تقنية
('IT-ADMIN', 'إدارة تقنية المعلومات', 'IT Administration', 'تقنية', 'إدارة أقسام تقنية المعلومات'),
('NET-ADMIN', 'إدارة الشبكات', 'Network Administration', 'تقنية', 'إدارة شبكات الحاسوب'),
('DB-ADMIN', 'إدارة قواعد البيانات', 'Database Administration', 'تقنية', 'إدارة قواعد البيانات'),
('SEC-ADMIN', 'إدارة أمن المعلومات', 'Security Administration', 'تقنية', 'إدارة أمن المعلومات'),

-- تخصصات موارد بشرية
('HR-ADMIN', 'إدارة الموارد البشرية', 'HR Administration', 'موارد بشرية', 'إدارة شؤون الموظفين'),
('RECRUITMENT', 'التوظيف', 'Recruitment', 'موارد بشرية', 'إدارة عمليات التوظيف'),
('TRAINING', 'التدريب', 'Training', 'موارد بشرية', 'إدارة التدريب والتطوير'),
('COMPENSATION', 'التعويضات', 'Compensation', 'موارد بشرية', 'إدارة الرواتب والحوافز'),

-- تخصصات مالية
('FIN-ADMIN', 'الإدارة المالية', 'Financial Administration', 'مالية', 'إدارة الشؤون المالية'),
('ACC-ADMIN', 'إدارة المحاسبة', 'Accounting Administration', 'مالية', 'إدارة الحسابات'),
('BUDGETING', 'إدارة الميزانية', 'Budget Management', 'مالية', 'إعداد وإدارة الميزانيات'),
('AUDITING', 'التدقيق', 'Auditing', 'مالية', 'إدارة التدقيق الداخلي والخارجي'),

-- تخصصات عمليات
('OPS-ADMIN', 'إدارة العمليات', 'Operations Administration', 'عمليات', 'إدارة العمليات التشغيلية'),
('LOG-ADMIN', 'إدارة اللوجستيات', 'Logistics Administration', 'عمليات', 'إدارة سلسلة التوريد'),
('PROD-ADMIN', 'إدارة الإنتاج', 'Production Administration', 'عمليات', 'إدارة عمليات الإنتاج'),
('QA-ADMIN', 'إدارة الجودة', 'Quality Administration', 'عمليات', 'إدارة أنظمة الجودة'),

-- تخصصات تسويق
('MKT-ADMIN', 'إدارة التسويق', 'Marketing Administration', 'تسويق', 'إدارة الأنشطة التسويقية'),
('SALES-ADMIN', 'إدارة المبيعات', 'Sales Administration', 'تسويق', 'إدارة فرق المبيعات'),
('PR-ADMIN', 'إدارة العلاقات العامة', 'Public Relations', 'تسويق', 'إدارة العلاقات العامة والإعلام')
ON CONFLICT (specialty_code) DO UPDATE SET
    specialty_name_ar = EXCLUDED.specialty_name_ar,
    specialty_name_en = EXCLUDED.specialty_name_en,
    field = EXCLUDED.field,
    description = EXCLUDED.description;

-- عرض عدد التخصصات
SELECT 
    '✅ Admin specialties seeded' AS status,
    COUNT(*) AS total_specialties
FROM hr.admin_specialties;