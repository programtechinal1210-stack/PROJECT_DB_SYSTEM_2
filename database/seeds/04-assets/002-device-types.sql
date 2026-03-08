 
-- =============================================
-- FILE: seeds/04-assets/003-device-types.sql
-- PURPOSE: إدراج أنواع الأجهزة
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج أنواع الأجهزة
INSERT INTO assets.device_types (
    type_code, 
    type_name_ar, 
    type_name_en, 
    description
) VALUES
('laptop', 'حاسوب محمول', 'Laptop', 'أجهزة حاسوب محمولة'),
('desktop', 'حاسوب مكتبي', 'Desktop', 'أجهزة حاسوب مكتبية'),
('tablet', 'جهاز لوحي', 'Tablet', 'أجهزة لوحية'),
('smartphone', 'هاتف ذكي', 'Smartphone', 'هواتف ذكية'),
('printer', 'طابعة', 'Printer', 'أجهزة طباعة'),
('scanner', 'ماسح ضوئي', 'Scanner', 'أجهزة مسح ضوئي'),
('router', 'جهاز توجيه', 'Router', 'أجهزة توجيه الشبكات'),
('switch', 'مبدل شبكي', 'Switch', 'مبدلات الشبكات'),
('firewall', 'جدار ناري', 'Firewall', 'أجهزة أمنية'),
('server', 'خادم', 'Server', 'أجهزة خوادم'),
('storage', 'وحدة تخزين', 'Storage', 'أجهزة تخزين'),
('radio', 'جهاز لاسلكي', 'Radio', 'أجهزة اتصال لاسلكي'),
('satellite', 'جهاز قمر صناعي', 'Satellite', 'أجهزة اتصال فضائي'),
('gps', 'جهاز تحديد موقع', 'GPS', 'أجهزة تحديد المواقع'),
('camera', 'كاميرا', 'Camera', 'أجهزة تصوير ومراقبة')
ON CONFLICT (type_code) DO UPDATE SET
    type_name_ar = EXCLUDED.type_name_ar,
    type_name_en = EXCLUDED.type_name_en,
    description = EXCLUDED.description;

-- إضافة المعدات المطلوبة لكل نوع
DO $$
DECLARE
    v_laptop_type_id INT;
    v_smartphone_type_id INT;
    v_router_type_id INT;
BEGIN
    -- الحصول على معرفات الأنواع
    SELECT type_id INTO v_laptop_type_id FROM assets.device_types WHERE type_code = 'laptop';
    SELECT type_id INTO v_smartphone_type_id FROM assets.device_types WHERE type_code = 'smartphone';
    SELECT type_id INTO v_router_type_id FROM assets.device_types WHERE type_code = 'router';
    
    -- معدات اللاب توب
    INSERT INTO assets.device_type_required_equipments (type_id, equipment_name_ar, equipment_name_en, is_required) VALUES
    (v_laptop_type_id, 'شاحن', 'Charger', true),
    (v_laptop_type_id, 'حقيبة', 'Bag', true),
    (v_laptop_type_id, 'فأرة', 'Mouse', false),
    (v_laptop_type_id, 'سماعات', 'Headphones', false)
    ON CONFLICT DO NOTHING;
    
    -- معدات الهاتف الذكي
    INSERT INTO assets.device_type_required_equipments (type_id, equipment_name_ar, equipment_name_en, is_required) VALUES
    (v_smartphone_type_id, 'شاحن', 'Charger', true),
    (v_smartphone_type_id, 'سماعات', 'Headphones', true),
    (v_smartphone_type_id, 'غطاء حماية', 'Protective Case', false)
    ON CONFLICT DO NOTHING;
    
    -- معدات الراوتر
    INSERT INTO assets.device_type_required_equipments (type_id, equipment_name_ar, equipment_name_en, is_required) VALUES
    (v_router_type_id, 'شاحن', 'Charger', true),
    (v_router_type_id, 'كابل شبكة', 'Network Cable', true),
    (v_router_type_id, 'هوائي', 'Antenna', true)
    ON CONFLICT DO NOTHING;
    
END $$;

-- عرض عدد أنواع الأجهزة
SELECT 
    '✅ Device types seeded' AS status,
    COUNT(*) AS total_types
FROM assets.device_types;