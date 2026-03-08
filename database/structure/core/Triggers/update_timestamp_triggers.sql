-- =============================================
-- FILE: structure/core/Triggers/update_timestamp_triggers.sql
-- PURPOSE: إنشاء triggers لتحديث حقول الوقت
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- دالة تحديث updated_at
CREATE OR REPLACE FUNCTION core.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger للمستخدمين
DROP TRIGGER IF EXISTS update_users_updated_at ON core.users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON core.users 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للأدوار
DROP TRIGGER IF EXISTS update_roles_updated_at ON core.roles;
CREATE TRIGGER update_roles_updated_at 
    BEFORE UPDATE ON core.roles 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للصلاحيات
DROP TRIGGER IF EXISTS update_permissions_updated_at ON core.permissions;
CREATE TRIGGER update_permissions_updated_at 
    BEFORE UPDATE ON core.permissions 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- Trigger للوحدات
DROP TRIGGER IF EXISTS update_modules_updated_at ON core.app_modules;
CREATE TRIGGER update_modules_updated_at 
    BEFORE UPDATE ON core.app_modules 
    FOR EACH ROW 
    EXECUTE FUNCTION core.update_updated_at_column();

-- رسالة تأكيد
SELECT '✅ Timestamp update triggers created successfully' AS status;