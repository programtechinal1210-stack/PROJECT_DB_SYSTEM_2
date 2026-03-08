 
-- =============================================
-- FILE: structure/core/Functions/Validation/fn_validate_username.sql
-- PURPOSE: دالة التحقق من اسم المستخدم
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_validate_username(p_username VARCHAR)
RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_username) < 3 THEN
        RETURN QUERY SELECT false, 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
        RETURN;
    END IF;
    
    IF LENGTH(p_username) > 50 THEN
        RETURN QUERY SELECT false, 'اسم المستخدم يجب أن يكون أقل من 50 حرف';
        RETURN;
    END IF;
    
    -- التحقق من الأحرف المسموحة (حروف وأرقام و _ . - فقط)
    IF NOT (p_username ~ '^[a-zA-Z0-9_.-]+$') THEN
        RETURN QUERY SELECT false, 'اسم المستخدم يمكن أن يحتوي فقط على حروف وأرقام و _ . -';
        RETURN;
    END IF;
    
    -- التحقق من عدم وجود كلمات ممنوعة
    IF p_username ILIKE '%admin%' OR p_username ILIKE '%root%' OR p_username ILIKE '%system%' THEN
        RETURN QUERY SELECT false, 'اسم المستخدم يحتوي على كلمات غير مسموحة';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'اسم المستخدم صالح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION core.fn_validate_username(VARCHAR) IS 'التحقق من صحة اسم المستخدم';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_username created successfully' AS status;