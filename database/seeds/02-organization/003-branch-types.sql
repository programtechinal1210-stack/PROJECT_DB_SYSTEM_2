-- =============================================
-- FILE: seeds/02-organization/003-branch-types.sql
-- PURPOSE: إدراج أنواع الفروع
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع الفروع
INSERT INTO organization.branch_types (
    type_code, 
    type_name_ar, 
    type_name_en, 
    sort_order, 
    is_active
) VALUES
('M1', 'فرع رئيسي مستوى 1', 'Main Branch Level 1', 1, true),
('M', 'فرع رئيسي', 'Main Branch', 2, true),
('S', 'فرع فرعي', 'Sub Branch', 3, true),
('F', 'فرع ميداني', 'Field Branch', 4, true)
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en,
    sort_order = EXCLUDED.sort_order;

-- عرض عدد أنواع الفروع
SELECT 
    '✅ Branch types seeded' AS status,
    COUNT(*) AS total_types
FROM organization.branch_types;