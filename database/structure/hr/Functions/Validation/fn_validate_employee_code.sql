 
-- =============================================
-- FILE: structure/hr/Functions/Validation/fn_validate_employee_code.sql
-- PURPOSE: دالة التحقق من صحة كود الموظف
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_validate_employee_code(
    p_employee_code VARCHAR,
    p_employee_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INT;
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_employee_code) < 3 OR LENGTH(p_employee_code) > 50 THEN
        RETURN QUERY SELECT false, 'كود الموظف يجب أن يكون بين 3 و 50 حرف';
        RETURN;
    END IF;
    
    -- التحقق من الأحرف المسموحة
    IF NOT (p_employee_code ~ '^[A-Za-z0-9_-]+$') THEN
        RETURN QUERY SELECT false, 'كود الموظف يمكن أن يحتوي فقط على حروف وأرقام و _ -';
        RETURN;
    END IF;
    
    -- التحقق من عدم التكرار
    SELECT COUNT(*) INTO v_count
    FROM hr.employees
    WHERE employee_code = p_employee_code
      AND (p_employee_id IS NULL OR employee_id != p_employee_id);
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'كود الموظف موجود مسبقاً';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'كود الموظف صالح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION hr.fn_validate_employee_code(VARCHAR, INT) IS 'التحقق من صحة كود الموظف';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_employee_code created successfully' AS status;