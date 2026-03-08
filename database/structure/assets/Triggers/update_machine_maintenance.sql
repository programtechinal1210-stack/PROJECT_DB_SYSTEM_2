-- =============================================
-- FILE: structure/assets/Triggers/update_machine_maintenance.sql
-- PURPOSE: تحديث تاريخ الصيانة القادم تلقائياً
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- دالة تحديث تاريخ الصيانة القادم
CREATE OR REPLACE FUNCTION assets.update_next_maintenance_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.last_maintenance_date IS DISTINCT FROM OLD.last_maintenance_date OR
       NEW.maintenance_interval IS DISTINCT FROM OLD.maintenance_interval THEN
        NEW.next_maintenance_date := assets.fn_calculate_next_maintenance(NEW.machine_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث تاريخ الصيانة
DROP TRIGGER IF EXISTS update_machine_maintenance ON assets.machines;
CREATE TRIGGER update_machine_maintenance
    BEFORE UPDATE OF last_maintenance_date, maintenance_interval ON assets.machines
    FOR EACH ROW
    EXECUTE FUNCTION assets.update_next_maintenance_date();

-- رسالة تأكيد
SELECT '✅ Machine maintenance update trigger created successfully' AS status;