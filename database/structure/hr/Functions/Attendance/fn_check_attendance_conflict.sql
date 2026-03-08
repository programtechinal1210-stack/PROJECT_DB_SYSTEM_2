 
-- =============================================
-- FILE: structure/hr/Functions/Attendance/fn_check_attendance_conflict.sql
-- PURPOSE: دالة التحقق من عدم وجود تعارض في الحضور
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_check_attendance_conflict(
    p_employee_id INT,
    p_date DATE,
    p_check_in TIME,
    p_check_out TIME,
    p_attendance_id BIGINT DEFAULT NULL
) RETURNS TABLE (
    has_conflict BOOLEAN,
    conflict_with_id BIGINT,
    conflict_description TEXT
) AS $$
DECLARE
    v_count INT;
    v_existing_id BIGINT;
BEGIN
    -- التحقق من وجود تداخل في الأوقات
    SELECT a.attendance_id, COUNT(*) INTO v_existing_id, v_count
    FROM hr.attendance a
    WHERE a.employee_id = p_employee_id
      AND a.attendance_date = p_date
      AND (p_attendance_id IS NULL OR a.attendance_id != p_attendance_id)
      AND (
          (a.check_in <= p_check_in AND a.check_out >= p_check_in) OR
          (a.check_in <= p_check_out AND a.check_out >= p_check_out) OR
          (a.check_in >= p_check_in AND a.check_out <= p_check_out)
      )
    GROUP BY a.attendance_id;
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT 
            true,
            v_existing_id,
            'يوجد تداخل في أوقات الحضور مع سجل آخر';
    ELSE
        RETURN QUERY SELECT 
            false,
            NULL::BIGINT,
            'لا يوجد تعارض';
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION hr.fn_check_attendance_conflict(INT, DATE, TIME, TIME, BIGINT) IS 'التحقق من عدم وجود تعارض في أوقات الحضور';

-- رسالة تأكيد
SELECT '✅ Function fn_check_attendance_conflict created successfully' AS status;