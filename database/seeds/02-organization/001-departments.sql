 
-- =============================================
-- FILE: seeds/02-organization/001-departments.sql
-- PURPOSE: إدراج الإدارات الأساسية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج الإدارات الأساسية
INSERT INTO organization.departments (
    department_code, 
    department_name_ar, 
    department_name_en, 
    description
) VALUES
('IT', 'تقنية المعلومات', 'Information Technology', 'إدارة تقنية المعلومات والدعم الفني'),
('HR', 'الموارد البشرية', 'Human Resources', 'إدارة شؤون الموظفين والتوظيف'),
('FIN', 'المالية', 'Finance', 'الإدارة المالية والمحاسبة'),
('OPS', 'العمليات', 'Operations', 'إدارة العمليات والتشغيل'),
('SALES', 'المبيعات', 'Sales', 'إدارة المبيعات والتسويق'),
('LOG', 'اللوجستيات', 'Logistics', 'إدارة اللوجستيات والتوريد'),
('PR', 'العلاقات العامة', 'Public Relations', 'إدارة العلاقات العامة والإعلام'),
('QA', 'الجودة', 'Quality Assurance', 'إدارة الجودة والتطوير'),
('RND', 'البحث والتطوير', 'Research & Development', 'إدارة البحث والتطوير'),
('LEGAL', 'الشؤون القانونية', 'Legal Affairs', 'الإدارة القانونية')
ON CONFLICT (department_code) DO UPDATE SET
    department_name_ar = EXCLUDED.department_name_ar,
    department_name_en = EXCLUDED.department_name_en,
    description = EXCLUDED.description;

-- عرض عدد الإدارات
SELECT 
    '✅ Departments seeded' AS status,
    COUNT(*) AS total_departments
FROM organization.departments;