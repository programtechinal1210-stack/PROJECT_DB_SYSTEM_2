-- =============================================
-- FILE: seeds/05-field/004-facility-types.sql
-- PURPOSE: إدراج أنواع المنشآت
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع المنشآت
INSERT INTO field.facility_types (
    type_code, 
    type_name_ar, 
    type_name_en, 
    type_category,
    description
) VALUES
-- منشآت تخزين
('storage_room', 'غرفة تخزين', 'Storage Room', 'storage', 'غرفة تخزين صغيرة'),
('warehouse', 'مستودع', 'Warehouse', 'storage', 'مستودع كبير للمواد'),
('fuel_depot', 'مستودع وقود', 'Fuel Depot', 'storage', 'مستودع لتخزين الوقود'),
('chemical_store', 'مستودع كيماويات', 'Chemical Store', 'storage', 'مستودع للمواد الكيميائية'),

-- منشآت تحت الأرض
('tunnel', 'نفق أرضي', 'Underground Tunnel', 'infrastructure', 'نفق تحت الأرض'),
('bunker', 'مخبأ', 'Bunker', 'infrastructure', 'مخبأ تحت الأرض'),
('underground_facility', 'منشأة تحت الأرض', 'Underground Facility', 'infrastructure', 'منشأة كاملة تحت الأرض'),

-- مباني
('admin_building', 'مبنى إداري', 'Administrative Building', 'building', 'مبنى للمكاتب الإدارية'),
('accommodation', 'سكن', 'Accommodation', 'building', 'سكن للموظفين'),
('cafeteria', 'مقصف', 'Cafeteria', 'building', 'مقصف للطعام'),

-- مرافق
('laboratory', 'معمل', 'Laboratory', 'facility', 'معمل للتحاليل'),
('control_center', 'مركز مراقبة', 'Control Center', 'facility', 'مركز تحكم ومراقبة'),
('first_aid', 'مركز إسعافات', 'First Aid Center', 'facility', 'مركز إسعافات أولية'),

-- مرافق طاقة
('power_station', 'محطة طاقة', 'Power Station', 'utility', 'محطة توليد طاقة'),
('generator_room', 'غرفة مولدات', 'Generator Room', 'utility', 'غرفة مولدات كهربائية'),
('water_treatment', 'محطة معالجة مياه', 'Water Treatment Plant', 'utility', 'محطة معالجة وتنقية مياه'),

-- مرافق أمنية
('security_gate', 'بوابة أمنية', 'Security Gate', 'security', 'بوابة دخول أمنية'),
('guard_post', 'برج حراسة', 'Guard Post', 'security', 'برج مراقبة أمنية'),
('security_room', 'غرفة أمن', 'Security Room', 'security', 'غرفة تحكم أمني'),

-- مرافق أخرى
('helipad', 'مهبط طائرات', 'Helipad', 'other', 'مهبط للطائرات المروحية'),
('workshop', 'ورشة', 'Workshop', 'other', 'ورشة صيانة'),
('prayer_room', 'مصلى', 'Prayer Room', 'other', 'مكان للصلاة')
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en,
    type_category = EXCLUDED.type_category,
    description = EXCLUDED.description;

-- عرض عدد أنواع المنشآت
SELECT 
    '✅ Facility types seeded' AS status,
    COUNT(*) AS total_types
FROM field.facility_types;