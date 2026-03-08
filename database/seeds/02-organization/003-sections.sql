 
-- =============================================
-- FILE: seeds/02-organization/002-sections.sql
-- PURPOSE: إدراج الأقسام الفرعية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج الأقسام الفرعية
INSERT INTO organization.sections (
    section_code, 
    section_name_ar, 
    section_name_en, 
    description
) VALUES
-- أقسام تقنية المعلومات
('DEV', 'التطوير', 'Development', 'تطوير البرمجيات والتطبيقات'),
('SUPPORT', 'الدعم الفني', 'Technical Support', 'دعم المستخدمين وحل المشكلات التقنية'),
('NETWORK', 'الشبكات', 'Networks', 'إدارة الشبكات والبنية التحتية'),
('SECURITY', 'أمن المعلومات', 'Information Security', 'أمن المعلومات والحماية'),

-- أقسام الموارد البشرية
('RECRUIT', 'التوظيف', 'Recruitment', 'استقطاب وتوظيف الكوادر'),
('TRAIN', 'التدريب', 'Training', 'تدريب وتطوير الموظفين'),
('PAYROLL', 'الرواتب', 'Payroll', 'إدارة الرواتب والمستحقات'),
('PERSONNEL', 'شؤون الموظفين', 'Personnel Affairs', 'شؤون الموظفين والإجراءات'),

-- أقسام المالية
('ACCOUNT', 'المحاسبة', 'Accounting', 'المحاسبة اليومية'),
('BUDGET', 'الميزانية', 'Budget', 'إعداد ومتابعة الميزانية'),
('AUDIT', 'التدقيق', 'Audit', 'التدقيق الداخلي'),
('TREASURY', 'الخزانة', 'Treasury', 'إدارة الخزانة'),

-- أقسام العمليات
('PROD', 'الإنتاج', 'Production', 'إدارة الإنتاج'),
('MAINT', 'الصيانة', 'Maintenance', 'الصيانة والتشغيل'),
('PLAN', 'التخطيط', 'Planning', 'تخطيط العمليات'),
('QUALITY', 'مراقبة الجودة', 'Quality Control', 'مراقبة الجودة'),

-- أقسام المبيعات
('MARKET', 'التسويق', 'Marketing', 'التسويق والإعلان'),
('SALES_TEAM', 'فريق المبيعات', 'Sales Team', 'فريق المبيعات المباشر'),
('CUSTOMER', 'خدمة العملاء', 'Customer Service', 'خدمة العملاء والدعم'),

-- أقسام اللوجستيات
('PROCURE', 'المشتريات', 'Procurement', 'المشتريات والتوريد'),
('WAREHOUSE', 'المستودعات', 'Warehouse', 'إدارة المستودعات'),
('TRANSPORT', 'النقل', 'Transportation', 'إدارة النقل والتوزيع')
ON CONFLICT (section_code) DO UPDATE SET
    section_name_ar = EXCLUDED.section_name_ar,
    section_name_en = EXCLUDED.section_name_en,
    description = EXCLUDED.description;

-- عرض عدد الأقسام
SELECT 
    '✅ Sections seeded' AS status,
    COUNT(*) AS total_sections
FROM organization.sections;