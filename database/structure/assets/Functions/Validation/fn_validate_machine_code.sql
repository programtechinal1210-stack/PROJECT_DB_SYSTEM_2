 
-- =============================================
-- FILE: structure/assets/Functions/Validation/fn_validate_machine_code.sql
-- PURPOSE: دالة التحقق من صحة كود الآلة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION assets.fn_validate_machine_code(
    p_machine_code VARCHAR,
    p_machine_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INT;
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_machine_code) < 3 OR LENGTH(p_machine_code) > 50 THEN
        RETURN QUERY SELECT false, 'كود الآلة يجب أن يكون بين 3 و 50 حرف';
        RETURN;
    END IF;
    
    -- التحقق من الأحرف المسموحة
    IF NOT (p_machine_code ~ '^[A-Za-z0-9_-]+$') THEN
        RETURN QUERY SELECT false, 'كود الآلة يمكن أن يحتوي فقط على حروف وأرقام و _ -';
        RETURN;
    END IF;
    
    -- التحقق من عدم التكرار
    SELECT COUNT(*) INTO v_count
    FROM assets.machines
    WHERE machine_code = p_machine_code
      AND (p_machine_id IS NULL OR machine_id != p_machine_id);
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'كود الآلة موجود مسبقاً';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'كود الآلة صالح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION assets.fn_validate_machine_code(VARCHAR, INT) IS 'التحقق من صحة كود الآلة';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_machine_code created successfully' AS status;