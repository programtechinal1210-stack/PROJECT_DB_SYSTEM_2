 
-- =============================================
-- FILE: structure/field/Functions/Geo/fn_get_sites_in_radius.sql
-- PURPOSE: دالة البحث عن المواقع ضمن نصف قطر محدد
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_get_sites_in_radius(
    p_lat DECIMAL,
    p_lng DECIMAL,
    p_radius_km DECIMAL,
    p_site_type_id INT DEFAULT NULL,
    p_min_elevation DECIMAL DEFAULT NULL,
    p_max_elevation DECIMAL DEFAULT NULL
) RETURNS TABLE (
    location_id INT,
    location_code VARCHAR,
    location_name_ar VARCHAR,
    distance_km DECIMAL,
    site_type_name VARCHAR,
    elevation DECIMAL,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.location_id,
        l.location_code,
        l.location_name_ar,
        field.fn_calculate_distance(p_lat, p_lng, l.latitude, l.longitude, 'km') AS distance_km,
        st.type_name_ar AS site_type_name,
        l.elevation,
        l.status
    FROM field.locations l
    LEFT JOIN field.site_types st ON l.site_type_id = st.type_id
    WHERE l.coordinates IS NOT NULL
      AND ST_DWithin(
          l.coordinates::geography,
          ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
          p_radius_km * 1000
      )
      AND (p_site_type_id IS NULL OR l.site_type_id = p_site_type_id)
      AND (p_min_elevation IS NULL OR l.elevation >= p_min_elevation)
      AND (p_max_elevation IS NULL OR l.elevation <= p_max_elevation)
    ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION field.fn_get_sites_in_radius(DECIMAL, DECIMAL, DECIMAL, INT, DECIMAL, DECIMAL) IS 'البحث عن المواقع ضمن نصف قطر محدد';

-- رسالة تأكيد
SELECT '✅ Function fn_get_sites_in_radius created successfully' AS status;