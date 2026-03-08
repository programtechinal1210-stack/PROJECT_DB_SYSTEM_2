 
-- =============================================
-- FILE: structure/assets/Types/tool_status.sql
-- PURPOSE: تعريف حالة الأداة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة الأداة
DO $$ BEGIN
    CREATE TYPE assets.tool_status AS ENUM (
        'available',   -- متاح
        'in_use',      -- مستعمل
        'maintenance', -- صيانة
        'lost',        -- مفقود
        'damaged'      -- تالف
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE assets.tool_status IS 'حالة الأداة: available (متاح)، in_use (مستعمل)، maintenance (صيانة)، lost (مفقود)، damaged (تالف)';

-- رسالة تأكيد
SELECT '✅ Type tool_status created successfully' AS status;