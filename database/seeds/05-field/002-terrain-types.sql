 
-- =============================================
-- FILE: seeds/05-field/002-terrain-types.sql
-- PURPOSE: إدراج أنواع التضاريس
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع التضاريس
INSERT INTO field.terrain_types (
    type_code, 
    type_name_ar, 
    type_name_en
) VALUES
('mountainous', 'جبلي', 'Mountainous'),
('coastal', 'ساحلي', 'Coastal'),
('desert', 'صحراوي', 'Desert'),
('urban', 'حضري', 'Urban'),
('rural', 'ريفي', 'Rural'),
('forest', 'غابي', 'Forest'),
('plain', 'سهلي', 'Plain'),
('valley', 'وادي', 'Valley'),
('plateau', 'هضبة', 'Plateau'),
('volcanic', 'بركاني', 'Volcanic'),
('wetland', 'أرض رطبة', 'Wetland'),
('arctic', 'قطبي', 'Arctic')
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en;

-- عرض عدد أنواع التضاريس
SELECT 
    '✅ Terrain types seeded' AS status,
    COUNT(*) AS total_types
FROM field.terrain_types;