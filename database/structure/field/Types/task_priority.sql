-- =============================================
-- FILE: structure/field/Types/task_priority.sql
-- PURPOSE: تعريف أولوية المهمة
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لأولوية المهمة
DO $$ BEGIN
    CREATE TYPE field.task_priority AS ENUM (
        'low',           -- منخفض
        'medium',        -- متوسط
        'high',          -- عالي
        'critical'       -- حرج
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.task_priority IS 'أولوية المهمة: low (منخفض)، medium (متوسط)، high (عالي)، critical (حرج)';

-- رسالة تأكيد
SELECT '✅ Type task_priority created successfully' AS status;