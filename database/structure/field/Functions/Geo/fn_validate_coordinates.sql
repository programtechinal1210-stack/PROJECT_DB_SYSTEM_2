 
-- =============================================
-- FILE: structure/field/Functions/Geo/fn_validate_coordinates.sql
-- PURPOSE: دالة التحقق من صحة الإحداثيات
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_validate_coordinates(
    p_latitude DECIMAL,
    p_longitude DECIMAL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- التحقق من نطاق خط العرض
    IF p_latitude < -90 OR p_latitude > 90 THEN
        RETURN QUERY SELECT false, 'خط العرض يجب أن يكون بين -90 و 90 درجة';
        RETURN;
    END IF;
    
    -- التحقق من نطاق خط الطول
    IF p_longitude < -180 OR p_longitude > 180 THEN
        RETURN QUERY SELECT false, 'خط الطول يجب أن يكون بين -180 و 180 درجة';
        RETURN;
    END IF;
    
    -- التحقق من القيم غير الصفرية (اختياري)
    IF p_latitude = 0 AND p_longitude = 0 THEN
        RETURN QUERY SELECT false, 'الإحداثيات (0,0) قد تكون قيمة افتراضية غير صحيحة';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'الإحداثيات صحيحة';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION field.fn_validate_coordinates(DECIMAL, DECIMAL) IS 'التحقق من صحة الإحداثيات الجغرافية';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_coordinates created successfully' AS status;