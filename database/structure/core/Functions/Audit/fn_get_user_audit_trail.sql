 
-- =============================================
-- FILE: structure/core/Functions/Audit/fn_get_user_audit_trail.sql
-- PURPOSE: دالة الحصول على سجل إجراءات المستخدم
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_get_user_audit_trail(
    p_user_id BIGINT,
    p_from_date TIMESTAMP DEFAULT NULL,
    p_to_date TIMESTAMP DEFAULT NULL
) RETURNS TABLE (
    audit_id BIGINT,
    action_time TIMESTAMP,
    action_type VARCHAR,
    details JSONB,
    ip_address INET
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.audit_id,
        al.changed_at,
        al.operation,
        al.new_data,
        al.ip_address
    FROM core.audit_log al
    WHERE al.record_id = p_user_id
      AND al.table_name = 'user_action'
      AND (p_from_date IS NULL OR al.changed_at >= p_from_date)
      AND (p_to_date IS NULL OR al.changed_at <= p_to_date)
    ORDER BY al.changed_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION core.fn_get_user_audit_trail(BIGINT, TIMESTAMP, TIMESTAMP) IS 'الحصول على سجل إجراءات المستخدم';

-- رسالة تأكيد
SELECT '✅ Function fn_get_user_audit_trail created successfully' AS status;