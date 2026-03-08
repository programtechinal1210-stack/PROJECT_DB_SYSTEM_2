 
-- =============================================
-- FILE: structure/field/Functions/Validation/fn_validate_location_code.sql
-- PURPOSE: دالة التحقق من صحة كود الموقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_validate_location_code(
    p_location_code VARCHAR,
    p_location_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INT;
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_location_code) < 2 OR LENGTH(p_location_code) > 50 THEN
        RETURN QUERY SELECT false, 'كود الموقع يجب أن يكون بين 2 و 50 حرف';
        RETURN;
    END IF;
    
    -- التحقق من الأحرف المسموحة
    IF NOT (p_location_code ~ '^[A-Za-z0-9_-]+$') THEN
        RETURN QUERY SELECT false, 'كود الموقع يمكن أن يحتوي فقط على حروف وأرقام و _ -';
        RETURN;
    END IF;
    
    -- التحقق من عدم التكرار
    SELECT COUNT(*) INTO v_count
    FROM field.locations
    WHERE location_code = p_location_code
      AND (p_location_id IS NULL OR location_id != p_location_id);
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'كود الموقع موجود مسبقاً';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'كود الموقع صالح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION field.fn_validate_location_code(VARCHAR, INT) IS 'التحقق من صحة كود الموقع';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_location_code created successfully' AS status;