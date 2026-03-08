 
-- =============================================
-- FILE: structure/hr/Tables/employee_assignments.sql
-- PURPOSE: إنشاء جدول تكليفات الموظفين (تاريخي)
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول تكليفات الموظفين
CREATE TABLE IF NOT EXISTS hr.employee_assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id) ON DELETE SET NULL,
    branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id) ON DELETE SET NULL,
    job_title VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    start_date DATE NOT NULL,
    end_date DATE,
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_assignment_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_at_least_one_assignment CHECK (
        branch_id IS NOT NULL OR 
        branch_dept_id IS NOT NULL OR 
        branch_dept_section_id IS NOT NULL
    )
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employee_assignments IS 'تكليفات الموظفين (تاريخية)';
COMMENT ON COLUMN hr.employee_assignments.assignment_id IS 'المعرف الفريد للتكليف';
COMMENT ON COLUMN hr.employee_assignments.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.employee_assignments.is_primary IS 'هل هذا هو التكليف الأساسي';
COMMENT ON COLUMN hr.employee_assignments.start_date IS 'تاريخ بدء التكليف';
COMMENT ON COLUMN hr.employee_assignments.end_date IS 'تاريخ انتهاء التكليف';

-- رسالة تأكيد
SELECT '✅ Table employee_assignments created successfully' AS status;