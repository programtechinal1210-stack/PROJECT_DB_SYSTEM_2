 
-- =============================================
-- FILE: structure/organization/Types/operational_status.sql
-- PURPOSE: تعريف حالة التشغيل
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لحالات التشغيل
DO $$ BEGIN
    CREATE TYPE organization.operational_status AS ENUM (
        'ready',       -- جاهز
        'active',      -- نشط
        'standby',     -- احتياط
        'maintenance'  -- صيانة
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE organization.operational_status IS 'حالة التشغيل: ready (جاهز)، active (نشط)، standby (احتياط)، maintenance (صيانة)';

-- رسالة تأكيد
SELECT '✅ Type operational_status created successfully' AS status;