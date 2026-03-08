-- =============================================
-- FILE: seeds/05-field/005-facility-properties.sql
-- PURPOSE: إدراج خصائص المنشآت
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_storage_type_id INT;
    v_building_type_id INT;
    v_lab_type_id INT;
BEGIN
    -- الحصول على معرفات أنواع المنشآت
    SELECT facility_type_id INTO v_storage_type_id FROM field.facility_types WHERE type_code = 'warehouse';
    SELECT facility_type_id INTO v_building_type_id FROM field.facility_types WHERE type_code = 'admin_building';
    SELECT facility_type_id INTO v_lab_type_id FROM field.facility_types WHERE type_code = 'laboratory';
    
    -- خصائص المستودعات
    INSERT INTO field.facility_properties (
        facility_type_id,
        property_name_ar,
        property_name_en,
        property_type,
        property_unit,
        is_required,
        display_order
    ) VALUES
    (v_storage_type_id, 'السعة التخزينية', 'Storage Capacity', 'numeric', 'م³', true, 1),
    (v_storage_type_id, 'درجة الحرارة', 'Temperature', 'numeric', '°C', true, 2),
    (v_storage_type_id, 'الرطوبة', 'Humidity', 'numeric', '%', true, 3),
    (v_storage_type_id, 'نوع التهوية', 'Ventilation Type', 'text', NULL, false, 4),
    (v_storage_type_id, 'عدد الرفوف', 'Number of Shelves', 'numeric', NULL, false, 5)
    ON CONFLICT DO NOTHING;
    
    -- خصائص المباني الإدارية
    INSERT INTO field.facility_properties (
        facility_type_id,
        property_name_ar,
        property_name_en,
        property_type,
        property_unit,
        is_required,
        display_order
    ) VALUES
    (v_building_type_id, 'عدد الطوابق', 'Number of Floors', 'numeric', NULL, true, 1),
    (v_building_type_id, 'عدد المكاتب', 'Number of Offices', 'numeric', NULL, true, 2),
    (v_building_type_id, 'مساحة المبنى', 'Building Area', 'numeric', 'م²', true, 3),
    (v_building_type_id, 'نوع التكييف', 'AC Type', 'text', NULL, true, 4),
    (v_building_type_id, 'توفر إنترنت', 'Internet Availability', 'boolean', NULL, true, 5)
    ON CONFLICT DO NOTHING;
    
    -- خصائص المعامل
    INSERT INTO field.facility_properties (
        facility_type_id,
        property_name_ar,
        property_name_en,
        property_type,
        property_unit,
        is_required,
        possible_values,
        display_order
    ) VALUES
    (v_lab_type_id, 'نوع المعمل', 'Lab Type', 'list', NULL, true, '["كيميائي", "فيزيائي", "بيولوجي", "جيولوجي"]'::jsonb, 1),
    (v_lab_type_id, 'عدد الأجهزة', 'Number of Equipment', 'numeric', NULL, true, NULL, 2),
    (v_lab_type_id, 'مستوى التعقيم', 'Sterilization Level', 'list', NULL, true, '["عالي", "متوسط", "عادي"]'::jsonb, 3),
    (v_lab_type_id, 'تهوية خاصة', 'Special Ventilation', 'boolean', NULL, true, NULL, 4),
    (v_lab_type_id, 'تاريخ التجهيز', 'Equipping Date', 'date', NULL, false, NULL, 5)
    ON CONFLICT DO NOTHING;
    
END $$;

-- عرض عدد الخصائص
SELECT 
    '✅ Facility properties seeded' AS status,
    COUNT(*) AS total_properties
FROM field.facility_properties;