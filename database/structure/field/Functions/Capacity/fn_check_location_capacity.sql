 
-- =============================================
-- FILE: structure/field/Functions/Capacity/fn_check_location_capacity.sql
-- PURPOSE: دالة التحقق من سعة الموقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_check_location_capacity(
    p_location_id INT,
    p_check_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    current_occupancy INT,
    max_capacity INT,
    available_spots INT,
    is_available BOOLEAN,
    utilization_percentage DECIMAL(5,2)
) AS $$
DECLARE
    v_max_capacity INT;
    v_current_count INT;
BEGIN
    -- الحصول على السعة القصوى للموقع
    SELECT capacity INTO v_max_capacity
    FROM field.locations
    WHERE location_id = p_location_id;
    
    -- حساب الإشغال الحالي
    SELECT COUNT(DISTINCT ta.employee_id) INTO v_current_count
    FROM field.tasks t
    JOIN field.task_assignments ta ON t.task_id = ta.task_id
    WHERE t.location_id = p_location_id
      AND t.status IN ('scheduled', 'in_progress')
      AND ta.employee_id IS NOT NULL
      AND (ta.start_date IS NULL OR ta.start_date <= p_check_date)
      AND (ta.end_date IS NULL OR ta.end_date >= p_check_date);
    
    -- إضافة الموظفين المقيمين في الموقع (من سكن الموقع)
    SELECT v_current_count + COUNT(*) INTO v_current_count
    FROM hr.employees e
    WHERE e.current_branch_id IN (
        SELECT branch_id FROM organization.branches 
        WHERE parent_branch_id = (SELECT branch_id FROM field.locations WHERE location_id = p_location_id)
    );
    
    -- تحضير النتيجة
    current_occupancy := COALESCE(v_current_count, 0);
    max_capacity := v_max_capacity;
    available_spots := GREATEST(v_max_capacity - COALESCE(v_current_count, 0), 0);
    is_available := COALESCE(v_current_count, 0) < v_max_capacity;
    utilization_percentage := CASE 
        WHEN v_max_capacity > 0 THEN 
            round((COALESCE(v_current_count, 0)::DECIMAL / v_max_capacity * 100), 2)
        ELSE 0
    END;
    
    RETURN QUERY SELECT 
        current_occupancy, 
        max_capacity, 
        available_spots, 
        is_available, 
        utilization_percentage;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION field.fn_check_location_capacity(INT, DATE) IS 'التحقق من سعة الموقع والإشغال الحالي';

-- رسالة تأكيد
SELECT '✅ Function fn_check_location_capacity created successfully' AS status;