-- =============================================
-- FILE: structure/field/Functions/Validation/fn_check_resource_availability.sql
-- PURPOSE: دالة التحقق من توفر الموارد لموقع معين
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_check_resource_availability(
    p_location_id INT,
    p_resource_type VARCHAR DEFAULT NULL
) RETURNS TABLE (
    resource_id INT,
    resource_name_ar VARCHAR,
    resource_type VARCHAR,
    available_quantity DECIMAL,
    unit VARCHAR,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        em.material_id,
        em.material_name_ar,
        em.material_type,
        em.quantity,
        em.unit,
        CASE 
            WHEN em.quantity <= 0 THEN 'غير متوفر'
            WHEN em.quantity <= em.reorder_level THEN 'محدود'
            ELSE 'متوفر'
        END AS status
    FROM field.exploration_materials em
    WHERE em.location_id = p_location_id
      AND (p_resource_type IS NULL OR em.material_type = p_resource_type)
      AND (em.expiry_date IS NULL OR em.expiry_date >= CURRENT_DATE)
    ORDER BY 
        CASE 
            WHEN em.quantity <= em.reorder_level THEN 2
            ELSE 1
        END,
        em.material_name_ar;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION field.fn_check_resource_availability(INT, VARCHAR) IS 'التحقق من توفر الموارد في موقع معين';

-- رسالة تأكيد
SELECT '✅ Function fn_check_resource_availability created successfully' AS status;