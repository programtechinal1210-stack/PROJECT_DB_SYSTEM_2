 
-- =============================================
-- FILE: structure/core/Tables/user_roles.sql
-- PURPOSE: إنشاء جدول ربط المستخدمين بالأدوار
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول ربط المستخدمين بالأدوار
CREATE TABLE IF NOT EXISTS core.user_roles (
    user_role_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES core.users(user_id) ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES core.roles(role_id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(user_id, role_id)
);

-- إضافة تعليقات
COMMENT ON TABLE core.user_roles IS 'ربط المستخدمين بالأدوار';
COMMENT ON COLUMN core.user_roles.user_role_id IS 'المعرف الفريد للربط';
COMMENT ON COLUMN core.user_roles.user_id IS 'معرف المستخدم';
COMMENT ON COLUMN core.user_roles.role_id IS 'معرف الدور';
COMMENT ON COLUMN core.user_roles.assigned_at IS 'تاريخ التعيين';
COMMENT ON COLUMN core.user_roles.assigned_by IS 'المستخدم الذي قام بالتعيين';

-- رسالة تأكيد
SELECT '✅ Table user_roles created successfully' AS status;