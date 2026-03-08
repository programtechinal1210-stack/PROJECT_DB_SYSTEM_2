 
-- =============================================
-- FILE: structure/assets/Types/machine_status.sql
-- PURPOSE: تعريف حالة الآلة
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة الآلة
DO $$ BEGIN
    CREATE TYPE assets.machine_status AS ENUM (
        'active',      -- نشط
        'inactive',    -- معطل
        'stored',      -- مخزن
        'maintenance', -- صيانة
        'reserved',    -- محجوز
        'transferred', -- منقول
        'scrapped'     -- مستبعد
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE assets.machine_status IS 'حالة الآلة: active (نشط)، inactive (معطل)، stored (مخزن)، maintenance (صيانة)، reserved (محجوز)، transferred (منقول)، scrapped (مستبعد)';

-- رسالة تأكيد
SELECT '✅ Type machine_status created successfully' AS status;