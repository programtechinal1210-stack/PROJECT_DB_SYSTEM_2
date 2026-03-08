 
-- =============================================
-- FILE: structure/field/Views/v_facility_inventory.sql
-- PURPOSE: عرض جرد المنشآت في المواقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW field.v_facility_inventory AS
SELECT 
    lf.facility_id,
    lf.facility_code,
    lf.facility_name_ar,
    lf.facility_name_en,
    l.location_name_ar AS location,
    ft.type_name_ar AS facility_type,
    ft.type_category,
    CASE 
        WHEN ft.type_category = 'storage' THEN 'تخزين'
        WHEN ft.type_category = 'infrastructure' THEN 'بنية تحتية'
        WHEN ft.type_category = 'building' THEN 'مبنى'
        WHEN ft.type_category = 'facility' THEN 'مرفق'
        WHEN ft.type_category = 'utility' THEN 'مرافق عامة'
        WHEN ft.type_category = 'security' THEN 'أمني'
        WHEN ft.type_category = 'accommodation' THEN 'سكن'
        WHEN ft.type_category = 'medical' THEN 'طبي'
        ELSE 'أخرى'
    END AS category_text,
    lf.is_required,
    lf.status,
    CASE 
        WHEN lf.status = 'planned' THEN 'مخطط'
        WHEN lf.status = 'under_construction' THEN 'قيد الإنشاء'
        WHEN lf.status = 'completed' THEN 'مكتمل'
        WHEN lf.status = 'inactive' THEN 'غير نشط'
        WHEN lf.status = 'maintenance' THEN 'قيد الصيانة'
        WHEN lf.status = 'decommissioned' THEN 'متوقف'
    END AS status_text,
    lf.installation_date,
    lf.capacity,
    lf.condition_rating,
    CASE 
        WHEN lf.condition_rating = 'excellent' THEN 'ممتاز'
        WHEN lf.condition_rating = 'good' THEN 'جيد'
        WHEN lf.condition_rating = 'fair' THEN 'متوسط'
        WHEN lf.condition_rating = 'poor' THEN 'سيئ'
        WHEN lf.condition_rating = 'dangerous' THEN 'خطير'
    END AS condition_text,
    lf.latitude,
    lf.longitude,
    
    -- عدد الخصائص المسجلة
    (SELECT COUNT(*) FROM field.facility_property_values WHERE facility_id = lf.facility_id) AS properties_count,
    
    lf.created_at,
    lf.updated_at
FROM field.location_facilities lf
JOIN field.locations l ON lf.location_id = l.location_id
JOIN field.facility_types ft ON lf.facility_type_id = ft.facility_type_id
ORDER BY l.location_name_ar, lf.facility_name_ar;

COMMENT ON VIEW field.v_facility_inventory IS 'جرد المنشآت في المواقع';

-- رسالة تأكيد
SELECT '✅ View v_facility_inventory created successfully' AS status;