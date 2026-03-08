-- =============================================
-- FILE: structure/hr/Triggers/update_timestamp_triggers.sql
-- PURPOSE: إنشاء triggers لتحديث حقول الوقت
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- Trigger للموظفين
DROP TRIGGER IF EXISTS update_employees_updated_at ON hr.employees;
CREATE TRIGGER update_employees_updated_at 
    BEFORE UPDATE ON hr.employees 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للمؤهلات
DROP TRIGGER IF EXISTS update_qualifications_updated_at ON hr.qualifications;
CREATE TRIGGER update_qualifications_updated_at 
    BEFORE UPDATE ON hr.qualifications 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للدورات التدريبية
DROP TRIGGER IF EXISTS update_training_courses_updated_at ON hr.training_courses;
CREATE TRIGGER update_training_courses_updated_at 
    BEFORE UPDATE ON hr.training_courses 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للمستويات الوظيفية
DROP TRIGGER IF EXISTS update_job_levels_updated_at ON hr.job_levels;
CREATE TRIGGER update_job_levels_updated_at 
    BEFORE UPDATE ON hr.job_levels 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للتخصصات الإدارية
DROP TRIGGER IF EXISTS update_admin_specialties_updated_at ON hr.admin_specialties;
CREATE TRIGGER update_admin_specialties_updated_at 
    BEFORE UPDATE ON hr.admin_specialties 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- رسالة تأكيد
SELECT '✅ HR timestamp triggers created successfully' AS status;