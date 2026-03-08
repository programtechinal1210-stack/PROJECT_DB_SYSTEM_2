 
-- =============================================
-- FILE: seeds/05-field/001-site-types.sql
-- PURPOSE: إدراج أنواع المواقع
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع المواقع
INSERT INTO field.site_types (
    type_code, 
    type_name_ar, 
    type_name_en
) VALUES
('drilling', 'موقع حفر', 'Drilling Site'),
('sampling', 'منطقة أخذ عينات', 'Sampling Area'),
('camp', 'مخيم عمل', 'Work Camp'),
('warehouse', 'مستودع معدات', 'Equipment Warehouse'),
('exploration', 'منطقة استكشاف', 'Exploration Area'),
('production', 'موقع إنتاج', 'Production Site'),
('laboratory', 'مختبر', 'Laboratory'),
('office', 'مكتب ميداني', 'Field Office'),
('helipad', 'مهبط طائرات', 'Helipad'),
('storage', 'منطقة تخزين', 'Storage Area'),
('maintenance', 'ورشة صيانة', 'Maintenance Workshop'),
('quarters', 'سكن', 'Living Quarters')
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en;

-- عرض عدد أنواع المواقع
SELECT 
    '✅ Site types seeded' AS status,
    COUNT(*) AS total_types
FROM field.site_types;