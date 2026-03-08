 -- =============================================
-- FILE: structure/hr/Functions/Attendance/fn_calculate_attendance_hours.sql
-- PURPOSE: دالة حساب ساعات الحضور
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_calculate_attendance_hours(
    p_employee_id INT,
    p_from_date DATE,
    p_to_date DATE
) RETURNS TABLE (
    total_days INT,
    present_days INT,
    absent_days INT,
    late_days INT,
    vacation_days INT,
    sick_days INT,
    total_hours DECIMAL(10,2),
    avg_hours_per_day DECIMAL(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INT AS total_days,
        COUNT(*) FILTER (WHERE status = 'present')::INT AS present_days,
        COUNT(*) FILTER (WHERE status = 'absent')::INT AS absent_days,
        COUNT(*) FILTER (WHERE status = 'late')::INT AS late_days,
        COUNT(*) FILTER (WHERE status = 'vacation')::INT AS vacation_days,
        COUNT(*) FILTER (WHERE status = 'sick')::INT AS sick_days,
        COALESCE(SUM(EXTRACT(EPOCH FROM (check_out - check_in))/3600), 0)::DECIMAL(10,2) AS total_hours,
        COALESCE(AVG(EXTRACT(EPOCH FROM (check_out - check_in))/3600), 0)::DECIMAL(10,2) AS avg_hours_per_day
    FROM hr.attendance
    WHERE employee_id = p_employee_id
      AND attendance_date BETWEEN p_from_date AND p_to_date;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION hr.fn_calculate_attendance_hours(INT, DATE, DATE) IS 'حساب ساعات الحضور لفترة محددة';

-- رسالة تأكيد
SELECT '✅ Function fn_calculate_attendance_hours created successfully' AS status;
