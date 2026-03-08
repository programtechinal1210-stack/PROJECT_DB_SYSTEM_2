 
-- =============================================
-- FILE: structure/hr/Tables/employee_job_levels.sql
-- PURPOSE: إنشاء جدول المستويات الوظيفية للموظفين (تاريخي)
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول المستويات الوظيفية للموظفين
CREATE TABLE IF NOT EXISTS hr.employee_job_levels (
    emp_level_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    level_id INT NOT NULL REFERENCES hr.job_levels(level_id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT true,
    start_date DATE NOT NULL,
    end_date DATE,
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(employee_id, level_id, start_date),
    
    -- القيود
    CONSTRAINT chk_level_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employee_job_levels IS 'المستويات الوظيفية للموظفين (تاريخي)';
COMMENT ON COLUMN hr.employee_job_levels.emp_level_id IS 'المعرف الفريد';
COMMENT ON COLUMN hr.employee_job_levels.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.employee_job_levels.level_id IS 'معرف المستوى الوظيفي';
COMMENT ON COLUMN hr.employee_job_levels.start_date IS 'تاريخ بداية المستوى';
COMMENT ON COLUMN hr.employee_job_levels.end_date IS 'تاريخ نهاية المستوى';

-- رسالة تأكيد
SELECT '✅ Table employee_job_levels created successfully' AS status;