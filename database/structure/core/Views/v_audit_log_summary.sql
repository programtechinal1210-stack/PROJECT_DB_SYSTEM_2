 
-- =============================================
-- FILE: structure/core/Views/v_audit_log_summary.sql
-- PURPOSE: ملخص سجل التدقيق
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW core.v_audit_log_summary AS
SELECT 
    DATE(changed_at) AS change_date,
    table_name,
    operation,
    COUNT(*) AS changes_count,
    COUNT(DISTINCT changed_by) AS unique_users,
    MIN(changed_at) AS first_change,
    MAX(changed_at) AS last_change
FROM core.audit_log
GROUP BY DATE(changed_at), table_name, operation
ORDER BY change_date DESC, table_name;

-- إضافة تعليق
COMMENT ON VIEW core.v_audit_log_summary IS 'ملخص يومي لسجل التدقيق';

-- رسالة تأكيد
SELECT '✅ View v_audit_log_summary created successfully' AS status;