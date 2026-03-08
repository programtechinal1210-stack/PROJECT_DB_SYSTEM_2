-- =============================================
-- FILE: structure/hr/Triggers/audit_triggers.sql
-- PURPOSE: إنشاء triggers للتسجيل التلقائي في audit_log
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- دالة تسجيل التغييرات للـ hr
CREATE OR REPLACE FUNCTION hr.audit_trigger_function()
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
    v_record_id := COALESCE(NEW.employee_id, OLD.employee_id);
    
    -- تسجيل حسب نوع العملية
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        INSERT INTO hr.audit_log (table_name, record_id, operation, new_data, changed_by)
        VALUES (TG_TABLE_NAME, v_record_id, 'INSERT', v_new_data, v_username);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- فقط إذا كان هناك تغيير فعلي
        IF OLD != NEW THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            INSERT INTO hr.audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
            VALUES (TG_TABLE_NAME, v_record_id, 'UPDATE', v_old_data, v_new_data, v_username);
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        INSERT INTO hr.audit_log (table_name, record_id, operation, old_data, changed_by)
        VALUES (TG_TABLE_NAME, v_record_id, 'DELETE', v_old_data, v_username);
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تفعيل التدقيق على الجداول المهمة
DROP TRIGGER IF EXISTS audit_employees ON hr.employees;
CREATE TRIGGER audit_employees
    AFTER INSERT OR UPDATE OR DELETE ON hr.employees
    FOR EACH ROW EXECUTE FUNCTION hr.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_employee_assignments ON hr.employee_assignments;
CREATE TRIGGER audit_employee_assignments
    AFTER INSERT OR UPDATE OR DELETE ON hr.employee_assignments
    FOR EACH ROW EXECUTE FUNCTION hr.audit_trigger_function();

DROP TRIGGER IF EXISTS audit_attendance ON hr.attendance;
CREATE TRIGGER audit_attendance
    AFTER INSERT OR UPDATE OR DELETE ON hr.attendance
    FOR EACH ROW EXECUTE FUNCTION hr.audit_trigger_function();

-- رسالة تأكيد
SELECT '✅ HR audit triggers created successfully' AS status;