 
-- =============================================
-- FILE: structure/hr/Types/employee_status.sql
-- PURPOSE: تعريف حالة الموظف
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة الموظف
DO $$ BEGIN
    CREATE TYPE hr.employee_status AS ENUM (
        'active',      -- نشط
        'vacation',    -- إجازة
        'sick',        -- مريض
        'terminated',  -- منتهى الخدمة
        'retired'      -- متقاعد
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE hr.employee_status IS 'حالة الموظف: active (نشط)، vacation (إجازة)، sick (مريض)، terminated (منتهى الخدمة)، retired (متقاعد)';

-- رسالة تأكيد
SELECT '✅ Type employee_status created successfully' AS status;