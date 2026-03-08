 
-- =============================================
-- FILE: structure/hr/Types/training_status.sql
-- PURPOSE: تعريف حالة التدريب
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة التدريب
DO $$ BEGIN
    CREATE TYPE hr.training_status AS ENUM (
        'enrolled',   -- ملتحق
        'completed',  -- منتهي
        'failed',     -- راسب
        'withdrawn'   -- متوقف
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE hr.training_status IS 'حالة التدريب: enrolled (ملتحق)، completed (منتهي)، failed (راسب)، withdrawn (متوقف)';

-- رسالة تأكيد
SELECT '✅ Type training_status created successfully' AS status;