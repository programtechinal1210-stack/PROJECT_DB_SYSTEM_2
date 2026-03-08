 
-- =============================================
-- FILE: structure/field/Types/site_type.sql
-- PURPOSE: تعريف نوع الموقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لأنواع المواقع
DO $$ BEGIN
    CREATE TYPE field.site_type AS ENUM (
        'drilling',      -- موقع حفر
        'sampling',      -- منطقة أخذ عينات
        'camp',          -- مخيم عمل
        'warehouse',     -- مستودع معدات
        'exploration',   -- منطقة استكشاف
        'production',    -- موقع إنتاج
        'laboratory',    -- معمل
        'office',        -- مكتب ميداني
        'helipad',       -- مهبط طائرات
        'storage',       -- منطقة تخزين
        'maintenance',   -- ورشة صيانة
        'quarters'       -- سكن
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.site_type IS 'نوع الموقع: drilling (حفر)، sampling (عينات)، camp (مخيم)، warehouse (مستودع)...';

-- رسالة تأكيد
SELECT '✅ Type site_type created successfully' AS status;