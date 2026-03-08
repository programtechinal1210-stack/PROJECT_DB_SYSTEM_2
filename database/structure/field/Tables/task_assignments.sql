 
-- =============================================
-- FILE: structure/field/Tables/task_assignments.sql
-- PURPOSE: إنشاء جدول تكليفات المهام
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول تكليفات المهام
CREATE TABLE IF NOT EXISTS field.task_assignments (
    assignment_id SERIAL PRIMARY KEY,
    task_id INT NOT NULL REFERENCES field.tasks(task_id) ON DELETE CASCADE,
    
    -- الجهة المنفذة (واحدة منها فقط)
    employee_id INT REFERENCES hr.employees(employee_id) ON DELETE SET NULL,
    machine_id INT REFERENCES assets.machines(machine_id) ON DELETE SET NULL,
    branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id) ON DELETE SET NULL,
    branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id) ON DELETE SET NULL,
    
    -- دور الجهة في المهمة
    role VARCHAR(255),
    responsibilities TEXT,
    
    -- فترة التكليف
    start_date DATE,
    end_date DATE,
    
    -- معلومات إضافية
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_task_assignment_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_at_least_one_assignee CHECK (
        employee_id IS NOT NULL OR
        machine_id IS NOT NULL OR
        branch_id IS NOT NULL OR
        branch_dept_id IS NOT NULL OR
        branch_dept_section_id IS NOT NULL
    )
);

-- إضافة تعليقات
COMMENT ON TABLE field.task_assignments IS 'تكليفات المهام';
COMMENT ON COLUMN field.task_assignments.assignment_id IS 'المعرف الفريد للتكليف';
COMMENT ON COLUMN field.task_assignments.task_id IS 'معرف المهمة';
COMMENT ON COLUMN field.task_assignments.employee_id IS 'الموظف المنفذ';
COMMENT ON COLUMN field.task_assignments.machine_id IS 'الآلة المنفذة';
COMMENT ON COLUMN field.task_assignments.role IS 'الدور في المهمة';

-- رسالة تأكيد
SELECT '✅ Table task_assignments created successfully' AS status;