 
-- =============================================
-- FILE: structure/assets/Views/v_device_inventory.sql
-- PURPOSE: عرض جرد أجهزة الاتصال
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW assets.v_device_inventory AS
SELECT 
    cd.device_id,
    cd.device_code,
    cd.device_name_ar,
    cd.serial_number,
    dt.type_name_ar AS device_type,
    cd.status,
    CASE 
        WHEN cd.status = 'active' THEN 'نشط'
        WHEN cd.status = 'inactive' THEN 'غير نشط'
        WHEN cd.status = 'maintenance' THEN 'صيانة'
        WHEN cd.status = 'lost' THEN 'مفقود'
    END AS status_text,
    cd.condition,
    CASE 
        WHEN cd.machine_id IS NOT NULL THEN (SELECT machine_code || ' - ' || machine_name_ar FROM assets.machines WHERE machine_id = cd.machine_id)
        WHEN cd.employee_id IS NOT NULL THEN (SELECT employee_code || ' - ' || full_name_ar FROM hr.employees WHERE employee_id = cd.employee_id)
        ELSE 'غير مرتبط'
    END AS assigned_to,
    (SELECT COUNT(*) FROM assets.actual_device_equipments WHERE device_id = cd.device_id AND condition != 'good') AS missing_equipments,
    cd.purchase_date,
    cd.warranty_expiry,
    CASE 
        WHEN cd.warranty_expiry < CURRENT_DATE THEN 'منتهية'
        WHEN cd.warranty_expiry < CURRENT_DATE + INTERVAL '30 days' THEN 'تنتهي قريباً'
        ELSE 'سارية'
    END AS warranty_status
FROM assets.communication_devices cd
LEFT JOIN assets.device_types dt ON cd.type_id = dt.type_id
ORDER BY cd.status, cd.device_name_ar;

COMMENT ON VIEW assets.v_device_inventory IS 'جرد أجهزة الاتصال';

-- رسالة تأكيد
SELECT '✅ View v_device_inventory created successfully' AS status;