-- =============================================
-- FILE: structure/assets/Types/resource_type.sql
-- PURPOSE: تعريف نوع المورد
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لأنواع الموارد
DO $$ BEGIN
    CREATE TYPE assets.resource_type AS ENUM (
        'fuel',           -- وقود
        'chemical',       -- مواد كيميائية
        'spare_part',     -- قطع غيار
        'consumable',     -- مواد استهلاكية
        'raw_material',   -- مواد خام
        'lubricant',      -- زيوت وشحوم
        'electrical',     -- مواد كهربائية
        'safety',         -- معدات سلامة
        'office',         -- لوازم مكتبية
        'cleaning'        -- مواد تنظيف
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE assets.resource_type IS 'نوع المورد: fuel (وقود)، chemical (كيماويات)، spare_part (قطع غيار)...';

-- رسالة تأكيد
SELECT '✅ Type resource_type created successfully' AS status;