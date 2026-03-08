-- =============================================
-- FILE: structure/core/Views/v_user_activity_summary.sql
-- PURPOSE: ملخص نشاط المستخدمين
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW core.v_user_activity_summary AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.created_at AS account_created,
    u.last_login AS last_login_time,
    u.last_login_ip AS last_login_ip,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN s.is_active THEN s.session_id END) AS active_sessions,
    COUNT(DISTINCT al.audit_id) AS total_actions,
    MAX(al.changed_at) AS last_action_time
FROM core.users u
LEFT JOIN core.user_sessions s ON u.user_id = s.user_id
LEFT JOIN core.audit_log al ON al.changed_by = u.username
GROUP BY u.user_id, u.username, u.email, u.created_at, u.last_login, u.last_login_ip;

-- إضافة تعليق
COMMENT ON VIEW core.v_user_activity_summary IS 'ملخص نشاط المستخدمين';

-- رسالة تأكيد
SELECT '✅ View v_user_activity_summary created successfully' AS status;