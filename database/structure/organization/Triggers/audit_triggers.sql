-- =============================================
-- FILE: structure/organization/Triggers/audit_triggers.sql
-- PURPOSE: إنشاء triggers للتسجيل التلقائي في audit_log
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- دالة تسجيل التغييرات للـ organization
CREATE OR REPLACE FUNCTION organization.audit_trigger_function()
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
        INSERT INTO organization.audit_log (table_name, record_id, operation, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.branch_id, 'INSERT', v_new_data, v_username);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- فقط إذا كان هناك تغيير فعلي
        IF OLD != NEW THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            INSERT INTO organization.audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
            VALUES (TG_TABLE_NAME, NEW.branch_id, 'UPDATE', v_old_data, v_new_data, v_username);
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        INSERT INTO organization.audit_log (table_name, record_id, operation, old_data, changed_by)
        VALUES (TG_TABLE_NAME, OLD.branch_id, 'DELETE', v_old_data, v_username);
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تفعيل التدقيق على الجداول المهمة
DROP TRIGGER IF EXISTS audit_branches ON organization.branches;
CREATE TRIGGER audit_branches
    AFTER INSERT OR UPDATE OR DELETE ON organization.branches
    FOR EACH ROW EXECUTE FUNCTION organization.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_departments ON organization.departments;
CREATE TRIGGER audit_departments
    AFTER INSERT OR UPDATE OR DELETE ON organization.departments
    FOR EACH ROW EXECUTE FUNCTION organization.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_sections ON organization.sections;
CREATE TRIGGER audit_sections
    AFTER INSERT OR UPDATE OR DELETE ON organization.sections
    FOR EACH ROW EXECUTE FUNCTION organization.audit_trigger_function();

-- رسالة تأكيد
SELECT '✅ Organization audit triggers created successfully' AS status;