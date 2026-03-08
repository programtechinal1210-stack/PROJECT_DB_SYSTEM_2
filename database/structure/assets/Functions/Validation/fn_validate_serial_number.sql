 
-- =============================================
-- FILE: structure/assets/Functions/Validation/fn_validate_serial_number.sql
-- PURPOSE: دالة التحقق من صحة الرقم التسلسلي
-- SCHEMA: assets
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION assets.fn_validate_serial_number(
    p_serial_number VARCHAR,
    p_asset_type VARCHAR,
    p_asset_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INT;
    v_table_name TEXT;
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_serial_number) < 3 OR LENGTH(p_serial_number) > 100 THEN
        RETURN QUERY SELECT false, 'الرقم التسلسلي يجب أن يكون بين 3 و 100 حرف';
        RETURN;
    END IF;
    
    -- تحديد الجدول حسب نوع الأصل
    CASE p_asset_type
        WHEN 'machine' THEN v_table_name := 'assets.machines';
        WHEN 'tool' THEN v_table_name := 'assets.tools';
        WHEN 'device' THEN v_table_name := 'assets.communication_devices';
        ELSE
            RETURN QUERY SELECT false, 'نوع الأصل غير صحيح';
            RETURN;
    END CASE;
    
    -- التحقق من عدم التكرار
    EXECUTE format('
        SELECT COUNT(*) FROM %s 
        WHERE serial_number = $1 
        AND ($2 IS NULL OR %s_id != $2)',
        v_table_name,
        CASE p_asset_type
            WHEN 'machine' THEN 'machine'
            WHEN 'tool' THEN 'tool'
            WHEN 'device' THEN 'device'
        END
    ) INTO v_count USING p_serial_number, p_asset_id;
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'الرقم التسلسلي موجود مسبقاً';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'الرقم التسلسلي صالح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION assets.fn_validate_serial_number(VARCHAR, VARCHAR, INT) IS 'التحقق من صحة الرقم التسلسلي';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_serial_number created successfully' AS status;