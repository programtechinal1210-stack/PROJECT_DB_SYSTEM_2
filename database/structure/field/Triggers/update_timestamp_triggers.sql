-- =============================================
-- FILE: structure/field/Triggers/update_timestamp_triggers.sql
-- PURPOSE: إنشاء triggers لتحديث حقول الوقت
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- Trigger للمواقع
DROP TRIGGER IF EXISTS update_locations_updated_at ON field.locations;
CREATE TRIGGER update_locations_updated_at 
    BEFORE UPDATE ON field.locations 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للمواقع الجيولوجية
DROP TRIGGER IF EXISTS update_geological_sites_updated_at ON field.geological_sites;
CREATE TRIGGER update_geological_sites_updated_at 
    BEFORE UPDATE ON field.geological_sites 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لمنشآت المواقع
DROP TRIGGER IF EXISTS update_facilities_updated_at ON field.location_facilities;
CREATE TRIGGER update_facilities_updated_at 
    BEFORE UPDATE ON field.location_facilities 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لمواد الاستكشاف
DROP TRIGGER IF EXISTS update_materials_updated_at ON field.exploration_materials;
CREATE TRIGGER update_materials_updated_at 
    BEFORE UPDATE ON field.exploration_materials 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للمهام
DROP TRIGGER IF EXISTS update_tasks_updated_at ON field.tasks;
CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON field.tasks 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لتعليقات المهام
DROP TRIGGER IF EXISTS update_task_comments_updated_at ON field.task_comments;
CREATE TRIGGER update_task_comments_updated_at 
    BEFORE UPDATE ON field.task_comments 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لأنواع المنشآت
DROP TRIGGER IF EXISTS update_facility_types_updated_at ON field.facility_types;
CREATE TRIGGER update_facility_types_updated_at 
    BEFORE UPDATE ON field.facility_types 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- رسالة تأكيد
SELECT '✅ Field timestamp triggers created successfully' AS status;