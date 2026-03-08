-- =============================================
-- FILE: seeds/04-assets/002-resource-types.sql
-- PURPOSE: إدراج أنواع الموارد
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع الموارد
INSERT INTO assets.resource_types (
    type_code, 
    type_name_ar, 
    type_name_en, 
    description
) VALUES
('fuel', 'وقود', 'Fuel', 'موارد الوقود والطاقة'),
('chemical', 'مواد كيميائية', 'Chemicals', 'المواد الكيميائية والمذيبات'),
('spare_part', 'قطع غيار', 'Spare Parts', 'قطع غيار الآلات والمعدات'),
('consumable', 'مواد استهلاكية', 'Consumables', 'المواد الاستهلاكية اليومية'),
('raw_material', 'مواد خام', 'Raw Materials', 'المواد الخام للإنتاج'),
('lubricant', 'زيوت وشحوم', 'Lubricants', 'زيوت التشحيم والشحوم'),
('electrical', 'مواد كهربائية', 'Electrical', 'المواد الكهربائية والإلكترونية'),
('safety', 'معدات سلامة', 'Safety Equipment', 'معدات السلامة والوقاية'),
('office', 'لوازم مكتبية', 'Office Supplies', 'اللوازم المكتبية'),
('cleaning', 'مواد تنظيف', 'Cleaning Materials', 'مواد التنظيف والصيانة')
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en,
    description = EXCLUDED.description;

-- عرض عدد أنواع الموارد
SELECT 
    '✅ Resource types seeded' AS status,
    COUNT(*) AS total_types
FROM assets.resource_types;