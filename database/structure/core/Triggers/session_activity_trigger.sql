-- =============================================
-- FILE: structure/core/Triggers/session_activity_trigger.sql
-- PURPOSE: تحديث آخر نشاط في الجلسة
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- دالة تحديث آخر نشاط
CREATE OR REPLACE FUNCTION core.update_session_activity()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_activity = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger للجلسات
DROP TRIGGER IF EXISTS update_session_activity ON core.user_sessions;
CREATE TRIGGER update_session_activity 
    BEFORE UPDATE ON core.user_sessions 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_session_activity();

-- رسالة تأكيد
SELECT '✅ Session activity trigger created successfully' AS status;