 
-- =============================================
-- FILE: structure/assets/Tables/machine_assignments.sql
-- PURPOSE: إنشاء جدول تكليفات الآلات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول تكليفات الآلات
CREATE TABLE IF NOT EXISTS assets.machine_assignments (
    assignment_id SERIAL PRIMARY KEY,
    machine_id INT NOT NULL REFERENCES assets.machines(machine_id) ON DELETE CASCADE,
    branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id) ON DELETE SET NULL,
    branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id) ON DELETE SET NULL,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
    removed_date DATE,
    assigned_by INT REFERENCES core.users(user_id),
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_assignment_dates CHECK (removed_date IS NULL OR removed_date >= assigned_date),
    CONSTRAINT chk_machine_assignment CHECK (
        branch_id IS NOT NULL OR
        branch_dept_id IS NOT NULL OR
        branch_dept_section_id IS NOT NULL
    )
);

-- إضافة تعليقات
COMMENT ON TABLE assets.machine_assignments IS 'تكليفات الآلات (تاريخي)';
COMMENT ON COLUMN assets.machine_assignments.assignment_id IS 'المعرف الفريد للتكليف';
COMMENT ON COLUMN assets.machine_assignments.machine_id IS 'معرف الآلة';
COMMENT ON COLUMN assets.machine_assignments.assigned_date IS 'تاريخ التكليف';
COMMENT ON COLUMN assets.machine_assignments.removed_date IS 'تاريخ الإزالة';

-- رسالة تأكيد
SELECT '✅ Table machine_assignments created successfully' AS status;