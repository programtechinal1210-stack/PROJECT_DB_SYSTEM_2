 
-- =============================================
-- FILE: structure/organization/Tables/branch_department_sections.sql
-- PURPOSE: إنشاء جدول ربط الفروع-الإدارات بالأقسام
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول ربط الفروع-الإدارات بالأقسام
CREATE TABLE IF NOT EXISTS organization.branch_dept_sections (
    branch_dept_section_id SERIAL PRIMARY KEY,
    branch_dept_id INT NOT NULL REFERENCES organization.branch_departments(branch_dept_id) ON DELETE CASCADE,
    section_id INT NOT NULL REFERENCES organization.sections(section_id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(branch_dept_id, section_id)
);

-- إضافة تعليقات
COMMENT ON TABLE organization.branch_dept_sections IS 'ربط الفروع-الإدارات بالأقسام';
COMMENT ON COLUMN organization.branch_dept_sections.branch_dept_section_id IS 'المعرف الفريد للربط';
COMMENT ON COLUMN organization.branch_dept_sections.branch_dept_id IS 'معرف ربط الفرع بالإدارة';
COMMENT ON COLUMN organization.branch_dept_sections.section_id IS 'معرف القسم';
COMMENT ON COLUMN organization.branch_dept_sections.is_active IS 'هل الربط نشط';

-- رسالة تأكيد
SELECT '✅ Table branch_dept_sections created successfully' AS status;