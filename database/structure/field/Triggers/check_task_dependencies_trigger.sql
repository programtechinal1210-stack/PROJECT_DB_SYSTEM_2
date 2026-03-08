-- =============================================
-- FILE: structure/field/Triggers/check_task_dependencies_trigger.sql
-- PURPOSE: التحقق من تبعيات المهام قبل التحديث
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- دالة التحقق من تبعيات المهام
CREATE OR REPLACE FUNCTION field.check_task_dependencies()
RETURNS TRIGGER AS $$
DECLARE
    v_dependency_count INT;
    v_unfinished_dependencies INT;
BEGIN
    -- فقط عند محاولة بدء المهمة
    IF NEW.status = 'in_progress' AND OLD.status = 'scheduled' THEN
        -- التحقق من وجود تبعيات غير مكتملة
        SELECT COUNT(*) INTO v_unfinished_dependencies
        FROM field.task_dependencies td
        JOIN field.tasks t ON td.depends_on_task_id = t.task_id
        WHERE td.task_id = NEW.task_id
          AND t.status NOT IN ('completed', 'cancelled');
        
        IF v_unfinished_dependencies > 0 THEN
            RAISE EXCEPTION 'لا يمكن بدء المهمة لأن المهام التابعة لها لم تكتمل بعد';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger للتحقق من التبعيات
DROP TRIGGER IF EXISTS check_task_dependencies ON field.tasks;
CREATE TRIGGER check_task_dependencies
    BEFORE UPDATE ON field.tasks
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION field.check_task_dependencies();

-- رسالة تأكيد
SELECT '✅ Task dependencies check trigger created successfully' AS status;