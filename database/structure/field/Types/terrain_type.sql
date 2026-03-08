 
-- =============================================
-- FILE: structure/field/Types/terrain_type.sql
-- PURPOSE: تعريف نوع التضاريس
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لأنواع التضاريس
DO $$ BEGIN
    CREATE TYPE field.terrain_type AS ENUM (
        'mountainous',   -- جبلي
        'coastal',       -- ساحلي
        'desert',        -- صحراوي
        'urban',         -- حضري
        'rural',         -- ريفي
        'forest',        -- غابي
        'plain',         -- سهلي
        'valley',        -- وادي
        'plateau',       -- هضبة
        'volcanic',      -- بركاني
        'wetland',       -- أرض رطبة
        'arctic'         -- قطبي
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.terrain_type IS 'نوع التضاريس: mountainous (جبلي)، coastal (ساحلي)، desert (صحراوي)...';

-- رسالة تأكيد
SELECT '✅ Type terrain_type created successfully' AS status;