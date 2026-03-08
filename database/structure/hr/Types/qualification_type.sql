-- =============================================
-- FILE: structure/hr/Types/qualification_type.sql
-- PURPOSE: تعريف نوع المؤهل
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لأنواع المؤهلات
DO $$ BEGIN
    CREATE TYPE hr.qualification_type AS ENUM (
        'educational',   -- تعليمي
        'professional',  -- مهني
        'technical',     -- تقني
        'certificate',   -- شهادة
        'diploma',       -- دبلوم
        'bachelor',      -- بكالوريوس
        'master',        -- ماجستير
        'doctorate',     -- دكتوراه
        'training',      -- دورة تدريبية
        'license'        -- رخصة
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE hr.qualification_type IS 'نوع المؤهل: educational (تعليمي)، professional (مهني)، technical (تقني)، certificate (شهادة)...';

-- رسالة تأكيد
SELECT '✅ Type qualification_type created successfully' AS status;