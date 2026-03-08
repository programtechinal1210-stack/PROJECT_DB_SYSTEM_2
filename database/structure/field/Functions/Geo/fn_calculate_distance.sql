 
-- =============================================
-- FILE: structure/field/Functions/Geo/fn_calculate_distance.sql
-- PURPOSE: دالة حساب المسافة بين موقعين
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_calculate_distance(
    p_lat1 DECIMAL,
    p_lon1 DECIMAL,
    p_lat2 DECIMAL,
    p_lon2 DECIMAL,
    p_unit VARCHAR DEFAULT 'km' -- 'km', 'm', 'miles'
) RETURNS DECIMAL AS $$
DECLARE
    v_distance DECIMAL;
    v_earth_radius DECIMAL;
BEGIN
    -- تحديد نصف قطر الأرض حسب الوحدة
    IF p_unit = 'km' THEN
        v_earth_radius := 6371; -- كيلومتر
    ELSIF p_unit = 'm' THEN
        v_earth_radius := 6371000; -- متر
    ELSIF p_unit = 'miles' THEN
        v_earth_radius := 3959; -- ميل
    ELSE
        v_earth_radius := 6371; -- افتراضي كيلومتر
    END IF;
    
    -- حساب المسافة باستخدام صيغة Haversine
    WITH radians AS (
        SELECT 
            radians(p_lat1) AS lat1_r,
            radians(p_lon1) AS lon1_r,
            radians(p_lat2) AS lat2_r,
            radians(p_lon2) AS lon2_r
    )
    SELECT 
        v_earth_radius * 2 * asin(
            sqrt(
                power(sin((lat2_r - lat1_r)/2), 2) +
                cos(lat1_r) * cos(lat2_r) *
                power(sin((lon2_r - lon1_r)/2), 2)
            )
        ) INTO v_distance
    FROM radians;
    
    RETURN round(v_distance, 2);
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION field.fn_calculate_distance(DECIMAL, DECIMAL, DECIMAL, DECIMAL, VARCHAR) IS 'حساب المسافة بين نقطتين جغرافيتين';

-- رسالة تأكيد
SELECT '✅ Function fn_calculate_distance created successfully' AS status;