 
-- =============================================
-- FILE: structure/core/Functions/Security/fn_generate_token.sql
-- PURPOSE: دالة توليد رمز عشوائي
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_generate_token(p_length INT DEFAULT 32)
RETURNS VARCHAR AS $$
BEGIN
    RETURN encode(gen_random_bytes(p_length), 'hex');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION core.fn_generate_token(INT) IS 'توليد رمز عشوائي بطول محدد';

-- رسالة تأكيد
SELECT '✅ Function fn_generate_token created successfully' AS status;