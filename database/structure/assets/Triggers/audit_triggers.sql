-- =============================================
-- FILE: structure/assets/Triggers/audit_triggers.sql
-- PURPOSE: إنشاء triggers للتسجيل التلقائي في audit_log
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- دالة تسجيل التغييرات للـ assets
CREATE OR REPLACE FUNCTION assets.audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_username VARCHAR(100);
    v_record_id BIGINT;
BEGIN
    -- الحصول على اسم المستخدم الحالي
    v_username := current_user;
    
    -- تحديد معرف السجل بناءً على الجدول
    v_record_id := COALESCE(
        NEW.machine_id, OLD.machine_id,
        NEW.tool_id, OLD.tool_id,
        NEW.resource_id, OLD.resource_id,
        NEW.device_id, OLD.device_id
    );
    
    -- تسجيل حسب نوع العملية
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        INSERT INTO assets.audit_log (table_name, record_id, operation, new_data, changed_by)
        VALUES (TG_TABLE_NAME, v_record_id, 'INSERT', v_new_data, v_username);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- فقط إذا كان هناك تغيير فعلي
        IF OLD != NEW THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            INSERT INTO assets.audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
            VALUES (TG_TABLE_NAME, v_record_id, 'UPDATE', v_old_data, v_new_data, v_username);
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        INSERT INTO assets.audit_log (table_name, record_id, operation, old_data, changed_by)
        VALUES (TG_TABLE_NAME, v_record_id, 'DELETE', v_old_data, v_username);
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تفعيل التدقيق على الجداول المهمة
DROP TRIGGER IF EXISTS audit_machines ON assets.machines;
CREATE TRIGGER audit_machines
    AFTER INSERT OR UPDATE OR DELETE ON assets.machines
    FOR EACH ROW EXECUTE FUNCTION assets.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_tools ON assets.tools;
CREATE TRIGGER audit_tools
    AFTER INSERT OR UPDATE OR DELETE ON assets.tools
    FOR EACH ROW EXECUTE FUNCTION assets.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_resources ON assets.resources;
CREATE TRIGGER audit_resources
    AFTER INSERT OR UPDATE OR DELETE ON assets.resources
    FOR EACH ROW EXECUTE FUNCTION assets.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_communication_devices ON assets.communication_devices;
CREATE TRIGGER audit_communication_devices
    AFTER INSERT OR UPDATE OR DELETE ON assets.communication_devices
    FOR EACH ROW EXECUTE FUNCTION assets.audit_trigger_function();

-- رسالة تأكيد
SELECT '✅ Assets audit triggers created successfully' AS status;