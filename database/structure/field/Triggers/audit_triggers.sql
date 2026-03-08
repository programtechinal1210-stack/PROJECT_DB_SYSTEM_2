-- =============================================
-- FILE: structure/field/Triggers/audit_triggers.sql
-- PURPOSE: إنشاء triggers للتسجيل التلقائي في audit_log
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- دالة تسجيل التغييرات للـ field
CREATE OR REPLACE FUNCTION field.audit_trigger_function()
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
        NEW.location_id, OLD.location_id,
        NEW.site_id, OLD.site_id,
        NEW.facility_id, OLD.facility_id,
        NEW.material_id, OLD.material_id,
        NEW.task_id, OLD.task_id
    );
    
    -- تسجيل حسب نوع العملية
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        INSERT INTO field.audit_log (table_name, record_id, operation, new_data, changed_by)
        VALUES (TG_TABLE_NAME, v_record_id, 'INSERT', v_new_data, v_username);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- فقط إذا كان هناك تغيير فعلي
        IF OLD != NEW THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            INSERT INTO field.audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
            VALUES (TG_TABLE_NAME, v_record_id, 'UPDATE', v_old_data, v_new_data, v_username);
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        INSERT INTO field.audit_log (table_name, record_id, operation, old_data, changed_by)
        VALUES (TG_TABLE_NAME, v_record_id, 'DELETE', v_old_data, v_username);
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تفعيل التدقيق على الجداول المهمة
DROP TRIGGER IF EXISTS audit_locations ON field.locations;
CREATE TRIGGER audit_locations
    AFTER INSERT OR UPDATE OR DELETE ON field.locations
    FOR EACH ROW EXECUTE FUNCTION field.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_geological_sites ON field.geological_sites;
CREATE TRIGGER audit_geological_sites
    AFTER INSERT OR UPDATE OR DELETE ON field.geological_sites
    FOR EACH ROW EXECUTE FUNCTION field.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_location_facilities ON field.location_facilities;
CREATE TRIGGER audit_location_facilities
    AFTER INSERT OR UPDATE OR DELETE ON field.location_facilities
    FOR EACH ROW EXECUTE FUNCTION field.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_exploration_materials ON field.exploration_materials;
CREATE TRIGGER audit_exploration_materials
    AFTER INSERT OR UPDATE OR DELETE ON field.exploration_materials
    FOR EACH ROW EXECUTE FUNCTION field.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_tasks ON field.tasks;
CREATE TRIGGER audit_tasks
    AFTER INSERT OR UPDATE OR DELETE ON field.tasks
    FOR EACH ROW EXECUTE FUNCTION field.audit_trigger_function();

-- رسالة تأكيد
SELECT '✅ Field audit triggers created successfully' AS status;