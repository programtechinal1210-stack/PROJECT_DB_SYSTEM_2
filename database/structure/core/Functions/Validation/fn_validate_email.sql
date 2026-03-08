 
-- =============================================
-- FILE: structure/core/Functions/Validation/fn_validate_email.sql
-- PURPOSE: دالة التحقق من صحة الإيميل
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_validate_email(p_email VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION core.fn_validate_email(VARCHAR) IS 'التحقق من صيغة البريد الإلكتروني';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_email created successfully' AS status;