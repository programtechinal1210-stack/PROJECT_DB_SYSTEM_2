 
-- =============================================
-- FILE: structure/assets/Tables/tool_assignments.sql
-- PURPOSE: إنشاء جدول تكليفات الأدوات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول تكليفات الأدوات
CREATE TABLE IF NOT EXISTS assets.tool_assignments (
    assignment_id SERIAL PRIMARY KEY,
    tool_id INT NOT NULL REFERENCES assets.tools(tool_id) ON DELETE CASCADE,
    employee_id INT REFERENCES hr.employees(employee_id) ON DELETE SET NULL,
    branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    assigned_by INT REFERENCES core.users(user_id),
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_return_date DATE,
    actual_return_date DATE,
    condition_on_return assets.equipment_condition,
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- القيود
    CONSTRAINT chk_assigned_to CHECK (
        (employee_id IS NOT NULL AND branch_id IS NULL) OR
        (employee_id IS NULL AND branch_id IS NOT NULL)
    ),
    CONSTRAINT chk_return_dates CHECK (actual_return_date IS NULL OR actual_return_date >= assigned_date)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.tool_assignments IS 'تكليفات الأدوات للموظفين أو الفروع';
COMMENT ON COLUMN assets.tool_assignments.assignment_id IS 'المعرف الفريد للتكليف';
COMMENT ON COLUMN assets.tool_assignments.tool_id IS 'معرف الأداة';
COMMENT ON COLUMN assets.tool_assignments.employee_id IS 'معرف الموظف (إذا كان التكليف لموظف)';
COMMENT ON COLUMN assets.tool_assignments.branch_id IS 'معرف الفرع (إذا كان التكليف لفرع)';
COMMENT ON COLUMN assets.tool_assignments.condition_on_return IS 'حالة الأداة عند الإرجاع';

-- رسالة تأكيد
SELECT '✅ Table tool_assignments created successfully' AS status;