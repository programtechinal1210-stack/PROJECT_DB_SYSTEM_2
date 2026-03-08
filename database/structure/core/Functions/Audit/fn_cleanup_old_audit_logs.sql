-- =============================================
-- FILE: structure/core/Functions/Audit/fn_cleanup_old_audit_logs.sql
-- PURPOSE: دالة تنظيف سجلات التدقيق القديمة
-- SCHEMA: core
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION core.fn_cleanup_old_audit_logs(
    p_days_to_keep INT DEFAULT 365,
    p_dry_run BOOLEAN DEFAULT false
) RETURNS TABLE (
    records_deleted BIGINT,
    date_from DATE,
    date_to DATE
) AS $$
DECLARE
    v_cutoff_date DATE;
    v_count BIGINT;
BEGIN
    v_cutoff_date := CURRENT_DATE - p_days_to_keep;
    
    IF p_dry_run THEN
        -- فقط حساب عدد السجلات
        SELECT COUNT(*) INTO v_count
        FROM core.audit_log
        WHERE changed_at < v_cutoff_date;
        
        RETURN QUERY SELECT v_count, v_cutoff_date, CURRENT_DATE;
    ELSE
        -- حذف السجلات القديمة
        WITH deleted AS (
            DELETE FROM core.audit_log
            WHERE changed_at < v_cutoff_date
            RETURNING audit_id
        )
        SELECT COUNT(*) INTO v_count FROM deleted;
        
        RETURN QUERY SELECT v_count, v_cutoff_date, CURRENT_DATE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION core.fn_cleanup_old_audit_logs(INT, BOOLEAN) IS 'تنظيف سجلات التدقيق الأقدم من عدد الأيام المحدد';

-- رسالة تأكيد
SELECT '✅ Function fn_cleanup_old_audit_logs created successfully' AS status;