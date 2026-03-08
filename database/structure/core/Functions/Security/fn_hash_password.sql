 
-- =============================================
-- FILE: structure/core/Functions/Security/fn_hash_password.sql
-- PURPOSE: دالة تشفير كلمة المرور
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_hash_password(p_password VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN crypt(p_password, gen_salt('bf', 10));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION core.fn_hash_password(VARCHAR) IS 'تشفير كلمة المرور باستخدام bcrypt';

-- رسالة تأكيد
SELECT '✅ Function fn_hash_password created successfully' AS status;