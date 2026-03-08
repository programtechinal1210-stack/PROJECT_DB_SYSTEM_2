 
-- =============================================
-- FILE: structure/organization/Tables/branch_departments.sql
-- PURPOSE: إنشاء جدول ربط الفروع بالإدارات
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول ربط الفروع بالإدارات
CREATE TABLE IF NOT EXISTS organization.branch_departments (
    branch_dept_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
    department_id INT NOT NULL REFERENCES organization.departments(department_id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(branch_id, department_id)
);

-- إضافة تعليقات
COMMENT ON TABLE organization.branch_departments IS 'ربط الفروع بالإدارات';
COMMENT ON COLUMN organization.branch_departments.branch_dept_id IS 'المعرف الفريد للربط';
COMMENT ON COLUMN organization.branch_departments.branch_id IS 'معرف الفرع';
COMMENT ON COLUMN organization.branch_departments.department_id IS 'معرف الإدارة';
COMMENT ON COLUMN organization.branch_departments.is_active IS 'هل الربط نشط';

-- رسالة تأكيد
SELECT '✅ Table branch_departments created successfully' AS status;