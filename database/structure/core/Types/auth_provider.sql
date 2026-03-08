 
-- =============================================
-- FILE: structure/core/Types/auth_provider.sql
-- PURPOSE: تعريف نوع مزود المصادقة
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لمزود المصادقة
DO $$ BEGIN
    CREATE TYPE core.auth_provider AS ENUM (
        'local',      -- محلي
        'google',     -- جوجل
        'microsoft',  -- مايكروسوفت
        'ldap'        -- LDAP
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE core.auth_provider IS 'مزود المصادقة: local (محلي)، google (جوجل)، microsoft (مايكروسوفت)، ldap (LDAP)';

-- رسالة تأكيد
SELECT '✅ Type auth_provider created successfully' AS status;