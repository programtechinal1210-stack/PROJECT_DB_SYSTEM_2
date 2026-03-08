-- =============================================
-- FILE: structure/field/Triggers/update_task_status_trigger.sql
-- PURPOSE: تحديث حالة المهمة تلقائياً بناءً على التواريخ
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- دالة تحديث حالة المهمة
CREATE OR REPLACE FUNCTION field.update_task_status()
RETURNS TRIGGER AS $$
BEGIN
    -- إذا كان تاريخ البدء قد حان والمهمة لا تزال مجدولة
    IF NEW.status = 'scheduled' AND NEW.start_date <= CURRENT_DATE THEN
        NEW.status := 'in_progress';
        NEW.updated_at := CURRENT_TIMESTAMP;
    END IF;
    
    -- إذا كان تاريخ الانتهاء قد مضى والمهمة لم تكتمل
    IF NEW.status IN ('scheduled', 'in_progress') 
       AND NEW.end_date IS NOT NULL 
       AND NEW.end_date < CURRENT_DATE THEN
        NEW.status := 'completed';
        NEW.completion_percentage := 100;
        NEW.updated_at := CURRENT_TIMESTAMP;
    END IF;
    
    -- إذا اكتملت المهمة بنسبة 100%
    IF NEW.completion_percentage = 100 AND NEW.status != 'completed' THEN
        NEW.status := 'completed';
        IF NEW.end_date IS NULL THEN
            NEW.end_date := CURRENT_DATE;
        END IF;
        NEW.updated_at := CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث حالة المهمة
DROP TRIGGER IF EXISTS update_task_status ON field.tasks;
CREATE TRIGGER update_task_status
    BEFORE INSERT OR UPDATE ON field.tasks
    FOR EACH ROW
    EXECUTE FUNCTION field.update_task_status();

-- رسالة تأكيد
SELECT '✅ Task status update trigger created successfully' AS status;