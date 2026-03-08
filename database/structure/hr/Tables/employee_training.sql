 
-- =============================================
-- FILE: structure/hr/Tables/employee_training.sql
-- PURPOSE: إنشاء جدول تدريب الموظفين
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول تدريب الموظفين
CREATE TABLE IF NOT EXISTS hr.employee_training (
    emp_training_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES hr.training_courses(course_id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT true,
    completion_date DATE,
    expiry_date DATE,
    score DECIMAL(5,2),
    status hr.training_status DEFAULT 'enrolled',
    certificate_url TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(employee_id, course_id),
    
    -- القيود
    CONSTRAINT chk_training_score CHECK (score BETWEEN 0 AND 100),
    CONSTRAINT chk_training_dates CHECK (expiry_date IS NULL OR expiry_date >= completion_date)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employee_training IS 'تدريب الموظفين';
COMMENT ON COLUMN hr.employee_training.emp_training_id IS 'المعرف الفريد';
COMMENT ON COLUMN hr.employee_training.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.employee_training.course_id IS 'معرف الدورة';
COMMENT ON COLUMN hr.employee_training.completion_date IS 'تاريخ الإكمال';
COMMENT ON COLUMN hr.employee_training.expiry_date IS 'تاريخ انتهاء الصلاحية';
COMMENT ON COLUMN hr.employee_training.status IS 'حالة التدريب';

-- رسالة تأكيد
SELECT '✅ Table employee_training created successfully' AS status;