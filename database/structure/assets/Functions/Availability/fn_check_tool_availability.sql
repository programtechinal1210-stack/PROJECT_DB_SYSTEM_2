 
-- =============================================
-- FILE: structure/assets/Functions/Availability/fn_check_tool_availability.sql
-- PURPOSE: دالة التحقق من توفر الأداة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION assets.fn_check_tool_availability(
    p_tool_id INT,
    p_check_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    is_available BOOLEAN,
    current_status assets.tool_status,
    assigned_to TEXT,
    expected_return_date DATE,
    message TEXT
) AS $$
DECLARE
    v_tool_status assets.tool_status;
    v_assignment RECORD;
BEGIN
    -- الحصول على حالة الأداة
    SELECT status INTO v_tool_status
    FROM assets.tools
    WHERE tool_id = p_tool_id;
    
    -- الحصول على التكليف النشط
    SELECT 
        ta.*,
        CASE 
            WHEN ta.employee_id IS NOT NULL THEN (SELECT full_name_ar FROM hr.employees WHERE employee_id = ta.employee_id)
            WHEN ta.branch_id IS NOT NULL THEN (SELECT branch_name_ar FROM organization.branches WHERE branch_id = ta.branch_id)
        END AS assigned_to_name
    INTO v_assignment
    FROM assets.tool_assignments ta
    WHERE ta.tool_id = p_tool_id
      AND ta.actual_return_date IS NULL
    ORDER BY ta.assigned_date DESC
    LIMIT 1;
    
    -- تحديد النتيجة
    is_available := v_tool_status = 'available' AND v_assignment IS NULL;
    current_status := v_tool_status;
    
    IF v_assignment IS NOT NULL THEN
        assigned_to := v_assignment.assigned_to_name;
        expected_return_date := v_assignment.expected_return_date;
        message := format('الأداة مستعملة من قبل %s منذ %s', 
            v_assignment.assigned_to_name, 
            v_assignment.assigned_date::TEXT);
    ELSIF v_tool_status != 'available' THEN
        message := format('الأداة غير متاحة - الحالة: %s', v_tool_status::TEXT);
    ELSE
        message := 'الأداة متاحة';
    END IF;
    
    RETURN QUERY SELECT is_available, current_status, assigned_to, expected_return_date, message;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION assets.fn_check_tool_availability(INT, DATE) IS 'التحقق من توفر الأداة';

-- رسالة تأكيد
SELECT '✅ Function fn_check_tool_availability created successfully' AS status;