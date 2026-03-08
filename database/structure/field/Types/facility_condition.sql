-- =============================================
-- FILE: structure/field/Types/facility_condition.sql
-- PURPOSE: تعريف حالة المنشأة
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة المنشأة
DO $$ BEGIN
    CREATE TYPE field.facility_condition AS ENUM (
        'excellent',    -- ممتاز
        'good',         -- جيد
        'fair',         -- متوسط
        'poor',         -- سيئ
        'dangerous'     -- خطير
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.facility_condition IS 'حالة المنشأة: excellent (ممتاز)، good (جيد)، fair (متوسط)، poor (سيئ)، dangerous (خطير)';

-- رسالة تأكيد
SELECT '✅ Type facility_condition created successfully' AS status;