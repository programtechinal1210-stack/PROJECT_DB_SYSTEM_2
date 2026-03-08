 
-- =============================================
-- FILE: structure/field/Types/exploration_phase.sql
-- PURPOSE: تعريف مرحلة الاستكشاف
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لمراحل الاستكشاف
DO $$ BEGIN
    CREATE TYPE field.exploration_phase AS ENUM (
        'initial',        -- مسح أولي
        'reconnaissance', -- استطلاع
        'geophysical',    -- مسح جيوفيزيائي
        'geochemical',    -- مسح جيوكيميائي
        'exploratory',    -- حفر استكشافي
        'detailed',       -- تقييم مفصل
        'feasibility',    -- دراسة جدوى
        'development',    -- تطوير
        'production',     -- إنتاج
        'closure',        -- إغلاق
        'rehabilitation'  -- تأهيل
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.exploration_phase IS 'مرحلة الاستكشاف: initial (أولي)، exploratory (استكشافي)، production (إنتاج)...';

-- رسالة تأكيد
SELECT '✅ Type exploration_phase created successfully' AS status;