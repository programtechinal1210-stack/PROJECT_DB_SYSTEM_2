 
-- =============================================
-- FILE: security/01-row-level-security.sql
-- PURPOSE: تفعيل Row Level Security على الجداول الحساسة
-- =============================================

\c project_db_system;

-- تفعيل RLS على جداول core
ALTER TABLE core.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.audit_log ENABLE ROW LEVEL SECURITY;

-- سياسات للمستخدمين
CREATE POLICY users_view_own ON core.users 
    FOR SELECT USING (current_user = username OR current_user = 'app_admin');

CREATE POLICY users_update_own ON core.users 
    FOR UPDATE USING (current_user = username OR current_user = 'app_admin');

-- سياسات لجلسات المستخدمين
CREATE POLICY sessions_view_own ON core.user_sessions 
    FOR SELECT USING (user_id = (SELECT user_id FROM core.users WHERE username = current_user));

CREATE POLICY sessions_manage_admin ON core.user_sessions 
    FOR ALL USING (current_user = 'app_admin');

-- سياسات لسجل التدقيق
CREATE POLICY audit_view_admin ON core.audit_log 
    FOR SELECT USING (current_user = 'app_admin');

-- رسالة تأكيد
SELECT '✅ Row Level Security policies created' AS status;