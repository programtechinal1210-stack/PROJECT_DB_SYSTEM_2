 
-- =============================================
-- FILE: structure/assets/Functions/Availability/fn_get_machine_resources.sql
-- PURPOSE: دالة الحصول على موارد الآلة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION assets.fn_get_machine_resources(
    p_machine_id INT
) RETURNS TABLE (
    resource_id INT,
    resource_code VARCHAR,
    resource_name_ar VARCHAR,
    required_quantity DECIMAL,
    current_quantity DECIMAL,
    unit VARCHAR,
    is_sufficient BOOLEAN,
    shortage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.resource_id,
        r.resource_code,
        r.resource_name_ar,
        mr.required_quantity,
        r.current_stock AS current_quantity,
        COALESCE(mr.unit, r.unit) AS unit,
        (r.current_stock >= mr.required_quantity) AS is_sufficient,
        GREATEST(mr.required_quantity - r.current_stock, 0) AS shortage
    FROM assets.machine_resources mr
    JOIN assets.resources r ON mr.resource_id = r.resource_id
    WHERE mr.machine_id = p_machine_id
    ORDER BY mr.required_quantity DESC;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION assets.fn_get_machine_resources(INT) IS 'الحصول على موارد الآلة والتحقق من كفايتها';

-- رسالة تأكيد
SELECT '✅ Function fn_get_machine_resources created successfully' AS status;