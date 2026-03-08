-- =============================================
-- FILE: structure/organization/Triggers/update_timestamp_triggers.sql
-- PURPOSE: إنشاء triggers لتحديث حقول الوقت
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- Trigger للفروع
DROP TRIGGER IF EXISTS update_branches_updated_at ON organization.branches;
CREATE TRIGGER update_branches_updated_at 
    BEFORE UPDATE ON organization.branches 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للإدارات
DROP TRIGGER IF EXISTS update_departments_updated_at ON organization.departments;
CREATE TRIGGER update_departments_updated_at 
    BEFORE UPDATE ON organization.departments 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للأقسام
DROP TRIGGER IF EXISTS update_sections_updated_at ON organization.sections;
CREATE TRIGGER update_sections_updated_at 
    BEFORE UPDATE ON organization.sections 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لربط الفروع بالإدارات
DROP TRIGGER IF EXISTS update_branch_departments_updated_at ON organization.branch_departments;
CREATE TRIGGER update_branch_departments_updated_at 
    BEFORE UPDATE ON organization.branch_departments 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger لربط الفروع-الإدارات بالأقسام
DROP TRIGGER IF EXISTS update_branch_dept_sections_updated_at ON organization.branch_dept_sections;
CREATE TRIGGER update_branch_dept_sections_updated_at 
    BEFORE UPDATE ON organization.branch_dept_sections 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- رسالة تأكيد
SELECT '✅ Organization timestamp triggers created successfully' AS status;