 
-- =============================================
-- FILE: structure/organization/Types/branch_type.sql
-- PURPOSE: تعريف نوع الفرع
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لأنواع الفروع
DO $$ BEGIN
    CREATE TYPE organization.branch_type AS ENUM (
        'M1',  -- فرع رئيسي مستوى 1
        'M',   -- فرع رئيسي
        'S',   -- فرع فرعي
        'F'    -- فرع ميداني
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE organization.branch_type IS 'نوع الفرع: M1 (رئيسي مستوى 1)، M (رئيسي)، S (فرعي)، F (ميداني)';

-- رسالة تأكيد
SELECT '✅ Type branch_type created successfully' AS status;