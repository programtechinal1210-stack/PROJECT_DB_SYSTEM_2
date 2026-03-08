 
-- =============================================
-- FILE: structure/core/Tables/permissions.sql
-- PURPOSE: إنشاء جدول الصلاحيات
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول الصلاحيات
CREATE TABLE IF NOT EXISTS core.permissions (
    permission_id SERIAL PRIMARY KEY,
    permission_code VARCHAR(100) UNIQUE NOT NULL,
    permission_name_ar VARCHAR(100) NOT NULL,
    permission_name_en VARCHAR(100),
    permission_description TEXT,
    module_id INT NOT NULL REFERENCES core.app_modules(module_id),
    action_type VARCHAR(20) NOT NULL,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_action_type CHECK (action_type IN ('create', 'read', 'update', 'delete', 'export', 'import', 'approve', 'reject'))
);

-- إضافة تعليقات
COMMENT ON TABLE core.permissions IS 'جدول الصلاحيات';
COMMENT ON COLUMN core.permissions.permission_id IS 'المعرف الفريد للصلاحية';
COMMENT ON COLUMN core.permissions.permission_code IS 'كود الصلاحية (مثل EMPLOYEES_VIEW)';
COMMENT ON COLUMN core.permissions.permission_name_ar IS 'اسم الصلاحية بالعربية';
COMMENT ON COLUMN core.permissions.permission_name_en IS 'اسم الصلاحية بالإنجليزية';
COMMENT ON COLUMN core.permissions.permission_description IS 'وصف الصلاحية';
COMMENT ON COLUMN core.permissions.module_id IS 'الوحدة المرتبطة بالصلاحية';
COMMENT ON COLUMN core.permissions.action_type IS 'نوع الإجراء';

-- رسالة تأكيد
SELECT '✅ Table permissions created successfully' AS status;