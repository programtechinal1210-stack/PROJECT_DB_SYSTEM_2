-- =============================================
-- FILE: structure/field/Types/task_status.sql
-- PURPOSE: تعريف حالة المهمة
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة المهمة
DO $$ BEGIN
    CREATE TYPE field.task_status AS ENUM (
        'scheduled',     -- مجدول
        'in_progress',   -- قيد التنفيذ
        'completed',     -- منتهي
        'cancelled',     -- ملغى
        'on_hold',       -- معلق
        'failed'         -- فاشل
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.task_status IS 'حالة المهمة: scheduled (مجدول)، in_progress (قيد التنفيذ)، completed (منتهي)...';

-- رسالة تأكيد
SELECT '✅ Type task_status created successfully' AS status;