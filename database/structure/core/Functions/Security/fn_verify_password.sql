 
-- =============================================
-- FILE: structure/core/Functions/Security/fn_verify_password.sql
-- PURPOSE: دالة التحقق من كلمة المرور
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_verify_password(
    p_password VARCHAR,
    p_hash VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN p_hash = crypt(p_password, p_hash);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION core.fn_verify_password(VARCHAR, VARCHAR) IS 'التحقق من تطابق كلمة المرور مع التشفير';

-- رسالة تأكيد
SELECT '✅ Function fn_verify_password created successfully' AS status;