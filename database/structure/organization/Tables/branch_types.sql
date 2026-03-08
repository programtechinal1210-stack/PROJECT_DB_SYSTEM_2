-- =============================================
-- FILE: structure/organization/Tables/branch_types.sql
-- PURPOSE: إنشاء جدول أنواع الفروع (Lookup)
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول أنواع الفروع
CREATE TABLE IF NOT EXISTS organization.branch_types (
    type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(10) UNIQUE NOT NULL,
    type_name_ar VARCHAR(100) NOT NULL,
    type_name_en VARCHAR(100),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id)
);

-- إضافة تعليقات
COMMENT ON TABLE organization.branch_types IS 'أنواع الفروع (بيانات ثابتة)';
COMMENT ON COLUMN organization.branch_types.type_id IS 'المعرف الفريد لنوع الفرع';
COMMENT ON COLUMN organization.branch_types.type_code IS 'كود النوع (M1, M, S, F)';
COMMENT ON COLUMN organization.branch_types.type_name_ar IS 'اسم النوع بالعربية';
COMMENT ON COLUMN organization.branch_types.type_name_en IS 'اسم النوع بالإنجليزية';
COMMENT ON COLUMN organization.branch_types.sort_order IS 'ترتيب العرض';
COMMENT ON COLUMN organization.branch_types.is_active IS 'هل النوع نشط';

-- رسالة تأكيد
SELECT '✅ Table branch_types created successfully' AS status;