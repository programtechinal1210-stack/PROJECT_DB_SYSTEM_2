-- =============================================
-- FILE: structure/assets/Triggers/update_timestamp_triggers.sql
-- PURPOSE: إنشاء triggers لتحديث حقول الوقت
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- Trigger للآلات
DROP TRIGGER IF EXISTS update_machines_updated_at ON assets.machines;
CREATE TRIGGER update_machines_updated_at 
    BEFORE UPDATE ON assets.machines 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للأدوات
DROP TRIGGER IF EXISTS update_tools_updated_at ON assets.tools;
CREATE TRIGGER update_tools_updated_at 
    BEFORE UPDATE ON assets.tools 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للموارد
DROP TRIGGER IF EXISTS update_resources_updated_at ON assets.resources;
CREATE TRIGGER update_resources_updated_at 
    BEFORE UPDATE ON assets.resources 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لأنواع الآلات
DROP TRIGGER IF EXISTS update_machine_types_updated_at ON assets.machine_types;
CREATE TRIGGER update_machine_types_updated_at 
    BEFORE UPDATE ON assets.machine_types 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لأجهزة الاتصال
DROP TRIGGER IF EXISTS update_communication_devices_updated_at ON assets.communication_devices;
CREATE TRIGGER update_communication_devices_updated_at 
    BEFORE UPDATE ON assets.communication_devices 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للأهداف
DROP TRIGGER IF EXISTS update_objectives_updated_at ON assets.objectives;
CREATE TRIGGER update_objectives_updated_at 
    BEFORE UPDATE ON assets.objectives 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- رسالة تأكيد
SELECT '✅ Assets timestamp triggers created successfully' AS status;