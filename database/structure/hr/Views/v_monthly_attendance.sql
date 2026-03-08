 
-- =============================================
-- FILE: structure/hr/Views/v_monthly_attendance.sql
-- PURPOSE: عرض ملخص الحضور الشهري
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW hr.v_monthly_attendance AS
SELECT 
    e.employee_id,
    e.employee_code,
    e.full_name_ar,
    b.branch_name_ar,
    DATE_TRUNC('month', a.attendance_date)::DATE AS month,
    COUNT(*) AS total_days,
    COUNT(*) FILTER (WHERE a.status = 'present') AS present_days,
    COUNT(*) FILTER (WHERE a.status = 'absent') AS absent_days,
    COUNT(*) FILTER (WHERE a.status = 'late') AS late_days,
    COUNT(*) FILTER (WHERE a.status = 'vacation') AS vacation_days,
    COUNT(*) FILTER (WHERE a.status = 'sick') AS sick_days,
    COUNT(*) FILTER (WHERE a.status = 'permission') AS permission_days,
    
    -- ساعات العمل
    SUM(EXTRACT(EPOCH FROM (a.check_out - a.check_in))/3600)::DECIMAL(10,2) FILTER (WHERE a.check_in IS NOT NULL AND a.check_out IS NOT NULL) AS total_hours,
    AVG(EXTRACT(EPOCH FROM (a.check_out - a.check_in))/3600)::DECIMAL(10,2) FILTER (WHERE a.check_in IS NOT NULL AND a.check_out IS NOT NULL) AS avg_hours_per_day
FROM hr.employees e
JOIN hr.attendance a ON e.employee_id = a.employee_id
LEFT JOIN organization.branches b ON e.current_branch_id = b.branch_id
GROUP BY e.employee_id, e.employee_code, e.full_name_ar, b.branch_name_ar, DATE_TRUNC('month', a.attendance_date)
ORDER BY month DESC, e.full_name_ar;

COMMENT ON VIEW hr.v_monthly_attendance IS 'ملخص الحضور الشهري للموظفين';

-- رسالة تأكيد
SELECT '✅ View v_monthly_attendance created successfully' AS status;