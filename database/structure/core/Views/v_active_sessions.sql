 
-- =============================================
-- FILE: structure/core/Views/v_active_sessions.sql
-- PURPOSE: عرض الجلسات النشطة
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW core.v_active_sessions AS
SELECT 
    s.session_id,
    u.user_id,
    u.username,
    u.email,
    s.ip_address,
    s.user_agent,
    s.device_info,
    s.login_at,
    s.last_activity,
    s.expires_at,
    EXTRACT(EPOCH FROM (s.expires_at - CURRENT_TIMESTAMP))::INT AS seconds_remaining,
    CASE 
        WHEN s.expires_at < CURRENT_TIMESTAMP THEN 'منتهية'
        WHEN s.last_activity < CURRENT_TIMESTAMP - INTERVAL '30 minutes' THEN 'خاملة'
        ELSE 'نشطة'
    END AS session_status
FROM core.user_sessions s
JOIN core.users u ON s.user_id = u.user_id
WHERE s.is_active = true
ORDER BY s.last_activity DESC;

-- إضافة تعليق
COMMENT ON VIEW core.v_active_sessions IS 'عرض الجلسات النشطة حالياً';

-- رسالة تأكيد
SELECT '✅ View v_active_sessions created successfully' AS status;