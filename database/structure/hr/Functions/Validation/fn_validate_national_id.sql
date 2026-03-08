 
-- =============================================
-- FILE: structure/hr/Functions/Validation/fn_validate_national_id.sql
-- PURPOSE: دالة التحقق من صحة رقم الهوية
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_validate_national_id(
    p_national_id VARCHAR,
    p_employee_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INT;
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_national_id) != 10 THEN
        RETURN QUERY SELECT false, 'رقم الهوية يجب أن يكون 10 أرقام';
        RETURN;
    END IF;
    
    -- التحقق من أن جميع الأحرف أرقام
    IF NOT (p_national_id ~ '^[0-9]+$') THEN
        RETURN QUERY SELECT false, 'رقم الهوية يجب أن يحتوي على أرقام فقط';
        RETURN;
    END IF;
    
    -- التحقق من عدم التكرار
    SELECT COUNT(*) INTO v_count
    FROM hr.employees
    WHERE national_id = p_national_id
      AND (p_employee_id IS NULL OR employee_id != p_employee_id);
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'رقم الهوية موجود مسبقاً';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'رقم الهوية صحيح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION hr.fn_validate_national_id(VARCHAR, INT) IS 'التحقق من صحة رقم الهوية';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_national_id created successfully' AS status;