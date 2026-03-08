 
-- =============================================
-- FILE: structure/core/Tables/role_permissions.sql
-- PURPOSE: إنشاء جدول ربط الأدوار بالصلاحيات
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول ربط الأدوار بالصلاحيات
CREATE TABLE IF NOT EXISTS core.role_permissions (
    role_permission_id BIGSERIAL PRIMARY KEY,
    role_id INT NOT NULL REFERENCES core.roles(role_id) ON DELETE CASCADE,
    permission_id INT NOT NULL REFERENCES core.permissions(permission_id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(role_id, permission_id)
);

-- إضافة تعليقات
COMMENT ON TABLE core.role_permissions IS 'ربط الأدوار بالصلاحيات';
COMMENT ON COLUMN core.role_permissions.role_permission_id IS 'المعرف الفريد للربط';
COMMENT ON COLUMN core.role_permissions.role_id IS 'معرف الدور';
COMMENT ON COLUMN core.role_permissions.permission_id IS 'معرف الصلاحية';
COMMENT ON COLUMN core.role_permissions.granted_at IS 'تاريخ المنح';
COMMENT ON COLUMN core.role_permissions.granted_by IS 'المستخدم الذي قام بالمنح';

-- رسالة تأكيد
SELECT '✅ Table role_permissions created successfully' AS status;