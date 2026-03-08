 
-- =============================================
-- FILE: structure/assets/Types/equipment_condition.sql
-- PURPOSE: تعريف حالة المعدات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة المعدات
DO $$ BEGIN
    CREATE TYPE assets.equipment_condition AS ENUM (
        'good',     -- جيد
        'damaged',  -- تالف
        'missing'   -- مفقود
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE assets.equipment_condition IS 'حالة المعدات: good (جيد)، damaged (تالف)، missing (مفقود)';

-- رسالة تأكيد
SELECT '✅ Type equipment_condition created successfully' AS status;