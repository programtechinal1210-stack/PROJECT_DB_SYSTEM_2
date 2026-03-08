 
-- =============================================
-- FILE: security/04-audit-triggers.sql
-- PURPOSE: إنشاء Triggers لتسجيل التغييرات
-- =============================================

\c project_db_system;

-- دالة عامة لتسجيل التغييرات
CREATE OR REPLACE FUNCTION audit.log_changes()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_username VARCHAR(100);
BEGIN
    -- الحصول على اسم المستخدم الحالي
    v_username := current_user;
    
    -- تسجيل البيانات حسب نوع العملية
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        INSERT INTO audit.audit_log (
            table_name, record_id, operation, new_data, changed_by
        ) VALUES (
            TG_TABLE_NAME, NEW.employee_id, 'INSERT', v_new_data, v_username
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        INSERT INTO audit.audit_log (
            table_name, record_id, operation, old_data, new_data, changed_by
        ) VALUES (
            TG_TABLE_NAME, NEW.employee_id, 'UPDATE', v_old_data, v_new_data, v_username
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        INSERT INTO audit.audit_log (
            table_name, record_id, operation, old_data, changed_by
        ) VALUES (
            TG_TABLE_NAME, OLD.employee_id, 'DELETE', v_old_data, v_username
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إنشاء Triggers للجداول المهمة (اختياري - يتم تفعيلها حسب الحاجة)
-- مثال لجدول الموظفين:
-- CREATE TRIGGER audit_employees
--     AFTER INSERT OR UPDATE OR DELETE ON hr.employees
--     FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

-- رسالة تأكيد
SELECT '✅ Audit triggers created' AS status;