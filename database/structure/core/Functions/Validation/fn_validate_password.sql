 
-- =============================================
-- FILE: structure/core/Functions/Validation/fn_validate_password.sql
-- PURPOSE: دالة التحقق من قوة كلمة المرور
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_validate_password(p_password VARCHAR)
RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT,
    strength INT
) AS $$
DECLARE
    v_length INT;
    v_has_upper BOOLEAN;
    v_has_lower BOOLEAN;
    v_has_number BOOLEAN;
    v_has_special BOOLEAN;
    v_strength INT := 0;
BEGIN
    v_length := LENGTH(p_password);
    v_has_upper := p_password ~ '[A-Z]';
    v_has_lower := p_password ~ '[a-z]';
    v_has_number := p_password ~ '[0-9]';
    v_has_special := p_password ~ '[!@#$%^&*()_+{}\[\]:;<>,.?~\\-]';
    
    -- حساب قوة كلمة المرور
    IF v_length >= 8 THEN v_strength := v_strength + 1; END IF;
    IF v_length >= 12 THEN v_strength := v_strength + 1; END IF;
    IF v_has_upper THEN v_strength := v_strength + 1; END IF;
    IF v_has_lower THEN v_strength := v_strength + 1; END IF;
    IF v_has_number THEN v_strength := v_strength + 1; END IF;
    IF v_has_special THEN v_strength := v_strength + 1; END IF;
    
    -- التحقق من الصلاحية (8 أحرف + حرف كبير + حرف صغير + رقم)
    is_valid := v_length >= 8 AND v_has_upper AND v_has_lower AND v_has_number;
    
    IF is_valid THEN
        message := 'كلمة المرور مقبولة';
    ELSE
        message := 'كلمة المرور يجب أن تكون 8 أحرف على الأقل، وتحتوي على حروف كبيرة وصغيرة وأرقام';
    END IF;
    
    RETURN QUERY SELECT is_valid, message, v_strength;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION core.fn_validate_password(VARCHAR) IS 'التحقق من قوة كلمة المرور';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_password created successfully' AS status;