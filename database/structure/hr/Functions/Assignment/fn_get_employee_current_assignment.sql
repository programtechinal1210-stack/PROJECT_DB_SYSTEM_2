 
-- =============================================
-- FILE: structure/hr/Functions/Assignment/fn_get_employee_current_assignment.sql
-- PURPOSE: دالة الحصول على التكليف الحالي للموظف
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_get_employee_current_assignment(
    p_employee_id INT,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    assignment_id INT,
    branch_id INT,
    branch_name_ar VARCHAR,
    department_id INT,
    department_name_ar VARCHAR,
    section_id INT,
    section_name_ar VARCHAR,
    job_title VARCHAR,
    is_primary BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ea.assignment_id,
        b.branch_id,
        b.branch_name_ar,
        d.department_id,
        d.department_name_ar,
        s.section_id,
        s.section_name_ar,
        ea.job_title,
        ea.is_primary
    FROM hr.employee_assignments ea
    LEFT JOIN organization.branches b ON ea.branch_id = b.branch_id
    LEFT JOIN organization.branch_departments bd ON ea.branch_dept_id = bd.branch_dept_id
    LEFT JOIN organization.departments d ON bd.department_id = d.department_id
    LEFT JOIN organization.branch_dept_sections bds ON ea.branch_dept_section_id = bds.branch_dept_section_id
    LEFT JOIN organization.sections s ON bds.section_id = s.section_id
    WHERE ea.employee_id = p_employee_id
      AND ea.start_date <= p_as_of_date
      AND (ea.end_date IS NULL OR ea.end_date >= p_as_of_date)
    ORDER BY ea.is_primary DESC, ea.start_date DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION hr.fn_get_employee_current_assignment(INT, DATE) IS 'الحصول على التكليف الحالي للموظف';

-- رسالة تأكيد
SELECT '✅ Function fn_get_employee_current_assignment created successfully' AS status;