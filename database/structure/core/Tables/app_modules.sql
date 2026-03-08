-- =============================================
-- FILE: structure/core/Tables/app_modules.sql
-- PURPOSE: إنشاء جدول وحدات التطبيق
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء جدول وحدات التطبيق
CREATE TABLE IF NOT EXISTS core.app_modules (
    module_id SERIAL PRIMARY KEY,
    module_code VARCHAR(50) UNIQUE NOT NULL,
    module_name_ar VARCHAR(100) NOT NULL,
    module_name_en VARCHAR(100),
    module_description TEXT,
    parent_module_id INT REFERENCES core.app_modules(module_id),
    module_level INT DEFAULT 1,
    display_order INT DEFAULT 0,
    icon VARCHAR(50),
    route VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE core.app_modules IS 'وحدات التطبيق (قائمة الوحدات المتاحة)';
COMMENT ON COLUMN core.app_modules.module_id IS 'المعرف الفريد للوحدة';
COMMENT ON COLUMN core.app_modules.module_code IS 'كود الوحدة (مثل EMPLOYEES, BRANCHES)';
COMMENT ON COLUMN core.app_modules.module_name_ar IS 'اسم الوحدة بالعربية';
COMMENT ON COLUMN core.app_modules.module_name_en IS 'اسم الوحدة بالإنجليزية';
COMMENT ON COLUMN core.app_modules.parent_module_id IS 'الوحدة الأب (للوحدات الفرعية)';
COMMENT ON COLUMN core.app_modules.module_level IS 'مستوى الوحدة في الشجرة';
COMMENT ON COLUMN core.app_modules.display_order IS 'ترتيب العرض';
COMMENT ON COLUMN core.app_modules.icon IS 'أيقونة الوحدة للواجهة';
COMMENT ON COLUMN core.app_modules.route IS 'مسار الوحدة في التطبيق';
COMMENT ON COLUMN core.app_modules.is_active IS 'هل الوحدة نشطة';

-- رسالة تأكيد
SELECT '✅ Table app_modules created successfully' AS status;