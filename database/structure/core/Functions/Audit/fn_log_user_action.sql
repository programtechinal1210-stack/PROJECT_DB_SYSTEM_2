 
-- =============================================
-- FILE: structure/core/Functions/Audit/fn_log_user_action.sql
-- PURPOSE: دالة تسجيل إجراءات المستخدم
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_log_user_action(
    p_user_id BIGINT,
    p_action VARCHAR,
    p_details JSONB DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
    v_username VARCHAR(100);
BEGIN
    -- الحصول على اسم المستخدم
    SELECT username INTO v_username FROM core.users WHERE user_id = p_user_id;
    
    -- تسجيل الإجراء
    INSERT INTO core.audit_log (
        table_name,
        record_id,
        operation,
        new_data,
        changed_by,
        ip_address
    ) VALUES (
        'user_action',
        p_user_id,
        p_action,
        p_details,
        v_username,
        inet_client_addr()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION core.fn_log_user_action(BIGINT, VARCHAR, JSONB) IS 'تسجيل إجراءات المستخدم';

-- رسالة تأكيد
SELECT '✅ Function fn_log_user_action created successfully' AS status;