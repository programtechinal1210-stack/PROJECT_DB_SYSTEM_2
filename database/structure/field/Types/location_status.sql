-- =============================================
-- FILE: structure/field/Types/location_status.sql
-- PURPOSE: تعريف حالة الموقع
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة الموقع
DO $$ BEGIN
    CREATE TYPE field.location_status AS ENUM (
        'safe',          -- آمن
        'contested',     -- متنازع عليه
        'dangerous',     -- خطير
        'unstable',      -- غير مستقر
        'restricted',    -- مقيد
        'closed'         -- مغلق
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.location_status IS 'حالة الموقع: safe (آمن)، contested (متنازع عليه)، dangerous (خطير)...';

-- رسالة تأكيد
SELECT '✅ Type location_status created successfully' AS status;