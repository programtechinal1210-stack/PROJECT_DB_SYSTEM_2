 
-- =============================================
-- FILE: structure/field/Types/facility_category.sql
-- PURPOSE: تعريف فئة المنشأة
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء نوع ENUM لفئات المنشآت
DO $$ BEGIN
    CREATE TYPE field.facility_category AS ENUM (
        'storage',          -- تخزين
        'infrastructure',   -- بنية تحتية
        'building',         -- مبنى
        'facility',         -- مرفق
        'utility',          -- مرافق عامة
        'security',         -- أمني
        'accommodation',    -- سكن
        'medical',          -- طبي
        'other'             -- أخرى
    );
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- إضافة تعليق على النوع
COMMENT ON TYPE field.facility_category IS 'فئة المنشأة: storage (تخزين)، infrastructure (بنية تحتية)، building (مبنى)...';

-- رسالة تأكيد
SELECT '✅ Type facility_category created successfully' AS status;