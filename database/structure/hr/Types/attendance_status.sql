 
-- =============================================
-- FILE: structure/hr/Types/attendance_status.sql
-- PURPOSE: تعريف حالة الحضور
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالة الحضور
DO $$ BEGIN
    CREATE TYPE hr.attendance_status AS ENUM (
        'present',   -- حاضر
        'absent',    -- غائب
        'vacation',  -- إجازة
        'sick',      -- مريض
        'late',      -- متأخر
        'permission' -- إذن
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE hr.attendance_status IS 'حالة الحضور: present (حاضر)، absent (غائب)، vacation (إجازة)، sick (مريض)، late (متأخر)، permission (إذن)';

-- رسالة تأكيد
SELECT '✅ Type attendance_status created successfully' AS status;