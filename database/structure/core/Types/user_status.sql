 
-- =============================================
-- FILE: structure/core/Types/user_status.sql
-- PURPOSE: تعريف نوع حالة المستخدم
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة المستخدم
DO $$ BEGIN
    CREATE TYPE core.user_status AS ENUM (
        'active',      -- نشط
        'inactive',    -- غير نشط
        'locked',      -- مقفل
        'pending'      -- قيد الانتظار
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE core.user_status IS 'حالة المستخدم: active (نشط)، inactive (غير نشط)، locked (مقفل)، pending (قيد الانتظار)';

-- رسالة تأكيد
SELECT '✅ Type user_status created successfully' AS status;