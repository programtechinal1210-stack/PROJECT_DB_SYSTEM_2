 
-- =============================================
-- FILE: structure/hr/Views/v_employee_training_status.sql
-- PURPOSE: عرض حالة تدريب الموظفين
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW hr.v_employee_training_status AS
SELECT 
    e.employee_id,
    e.employee_code,
    e.full_name_ar,
    tc.course_id,
    tc.course_code,
    tc.course_name_ar,
    et.is_required,
    et.completion_date,
    et.expiry_date,
    et.status,
    et.score,
    CASE 
        WHEN et.status = 'completed' AND et.expiry_date IS NOT NULL AND et.expiry_date < CURRENT_DATE THEN 'منتهي الصلاحية'
        WHEN et.status = 'completed' AND et.expiry_date IS NOT NULL AND et.expiry_date < CURRENT_DATE + INTERVAL '30 days' THEN 'سينتهي قريباً'
        WHEN et.status = 'completed' THEN 'مكتمل'
        WHEN et.status = 'enrolled' THEN 'قيد التنفيذ'
        WHEN et.status = 'failed' THEN 'راسب'
        WHEN et.status = 'withdrawn' THEN 'منسحب'
    END AS status_text,
    CASE 
        WHEN et.expiry_date IS NOT NULL THEN EXTRACT(DAY FROM (et.expiry_date - CURRENT_DATE))::INT
        ELSE NULL
    END AS days_remaining
FROM hr.employees e
JOIN hr.employee_training et ON e.employee_id = et.employee_id
JOIN hr.training_courses tc ON et.course_id = tc.course_id
WHERE e.is_active = true
ORDER BY e.full_name_ar, tc.course_name_ar;

COMMENT ON VIEW hr.v_employee_training_status IS 'حالة تدريب الموظفين';

-- رسالة تأكيد
SELECT '✅ View v_employee_training_status created successfully' AS status;