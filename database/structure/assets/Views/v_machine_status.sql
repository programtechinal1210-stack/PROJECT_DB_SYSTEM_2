 
-- =============================================
-- FILE: structure/assets/Views/v_machine_status.sql
-- PURPOSE: عرض حالة الآلات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW assets.v_machine_status AS
SELECT 
    m.machine_id,
    m.machine_code,
    m.machine_name_ar,
    m.serial_number,
    mt.type_name_ar AS machine_type,
    ms.status_name_ar AS current_status,
    m.last_maintenance_date,
    m.next_maintenance_date,
    CASE 
        WHEN m.next_maintenance_date < CURRENT_DATE THEN 'متأخرة'
        WHEN m.next_maintenance_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'خلال أسبوع'
        WHEN m.next_maintenance_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'خلال شهر'
        ELSE 'مجدولة'
    END AS maintenance_status,
    b.branch_name_ar AS current_location,
    m.required_employees,
    (SELECT COUNT(*) FROM assets.machine_assignments WHERE machine_id = m.machine_id AND removed_date IS NULL) AS active_assignments,
    m.created_at
FROM assets.machines m
LEFT JOIN assets.machine_types mt ON m.machine_type_id = mt.type_id
LEFT JOIN assets.machine_statuses ms ON m.status_id = ms.status_id
LEFT JOIN organization.branches b ON m.current_branch_id = b.branch_id
WHERE m.status_id = 1 -- active only
ORDER BY m.next_maintenance_date;

COMMENT ON VIEW assets.v_machine_status IS 'حالة الآلات النشطة ومواعيد الصيانة';

-- رسالة تأكيد
SELECT '✅ View v_machine_status created successfully' AS status;