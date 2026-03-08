-- =============================================
-- FILE: structure/core/Triggers/audit_triggers.sql
-- PURPOSE: إنشاء triggers للتسجيل التلقائي في audit_log
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- دالة تسجيل التغييرات
CREATE OR REPLACE FUNCTION core.audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_username VARCHAR(100);
BEGIN
    -- الحصول على اسم المستخدم الحالي
    v_username := current_user;
    
    -- تسجيل حسب نوع العملية
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        INSERT INTO core.audit_log (table_name, record_id, operation, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.user_id, 'INSERT', v_new_data, v_username);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- فقط إذا كان هناك تغيير فعلي
        IF OLD != NEW THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            INSERT INTO core.audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
            VALUES (TG_TABLE_NAME, NEW.user_id, 'UPDATE', v_old_data, v_new_data, v_username);
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        INSERT INTO core.audit_log (table_name, record_id, operation, old_data, changed_by)
        VALUES (TG_TABLE_NAME, OLD.user_id, 'DELETE', v_old_data, v_username);
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تفعيل التدقيق على الجداول المهمة
DROP TRIGGER IF EXISTS audit_users ON core.users;
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON core.users
    FOR EACH ROW EXECUTE FUNCTION core.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_roles ON core.roles;
CREATE TRIGGER audit_roles
    AFTER INSERT OR UPDATE OR DELETE ON core.roles
    FOR EACH ROW EXECUTE FUNCTION core.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_permissions ON core.permissions;
CREATE TRIGGER audit_permissions
    AFTER INSERT OR UPDATE OR DELETE ON core.permissions
    FOR EACH ROW EXECUTE FUNCTION core.audit_trigger_function();

-- رسالة تأكيد
SELECT '✅ Audit triggers created successfully' AS status;