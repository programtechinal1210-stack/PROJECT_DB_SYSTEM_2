 
-- =============================================
-- FILE: structure/hr/Functions/Validation/fn_check_qualification_expiry.sql
-- PURPOSE: دالة التحقق من انتهاء صلاحية المؤهلات
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_check_qualification_expiry(
    p_employee_id INT DEFAULT NULL
) RETURNS TABLE (
    employee_id INT,
    employee_name VARCHAR,
    qualification_name VARCHAR,
    expiry_date DATE,
    days_remaining INT,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.employee_id,
        e.full_name_ar,
        q.qualification_name_ar,
        et.expiry_date,
        EXTRACT(DAY FROM (et.expiry_date - CURRENT_DATE))::INT AS days_remaining,
        CASE 
            WHEN et.expiry_date < CURRENT_DATE THEN 'منتهي'
            WHEN et.expiry_date < CURRENT_DATE + INTERVAL '30 days' THEN 'سينتهي قريباً'
            ELSE 'ساري'
        END AS status
    FROM hr.employees e
    JOIN hr.employee_training et ON e.employee_id = et.employee_id
    JOIN hr.training_courses q ON et.course_id = q.course_id
    WHERE (p_employee_id IS NULL OR e.employee_id = p_employee_id)
      AND et.expiry_date IS NOT NULL
      AND et.status = 'completed'
    ORDER BY et.expiry_date;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION hr.fn_check_qualification_expiry(INT) IS 'التحقق من انتهاء صلاحية المؤهلات';

-- رسالة تأكيد
SELECT '✅ Function fn_check_qualification_expiry created successfully' AS status;