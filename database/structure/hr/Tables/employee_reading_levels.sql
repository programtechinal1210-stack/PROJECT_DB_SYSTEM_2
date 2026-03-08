 
-- =============================================
-- FILE: structure/hr/Tables/employee_reading_levels.sql
-- PURPOSE: إنشاء جدول مستويات القراءة للموظفين
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول مستويات القراءة للموظفين
CREATE TABLE IF NOT EXISTS hr.employee_reading_levels (
    emp_reading_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    reading_level_id INT NOT NULL REFERENCES hr.reading_levels(reading_level_id) ON DELETE CASCADE,
    test_date DATE NOT NULL,
    expiry_date DATE,
    score DECIMAL(5,2),
    status hr.training_status DEFAULT 'enrolled',
    evaluator VARCHAR(255),
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_reading_score CHECK (score BETWEEN 0 AND 100),
    CONSTRAINT chk_test_date CHECK (test_date <= CURRENT_DATE)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employee_reading_levels IS 'مستويات القراءة للموظفين';
COMMENT ON COLUMN hr.employee_reading_levels.emp_reading_id IS 'المعرف الفريد';
COMMENT ON COLUMN hr.employee_reading_levels.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.employee_reading_levels.reading_level_id IS 'معرف مستوى القراءة';
COMMENT ON COLUMN hr.employee_reading_levels.test_date IS 'تاريخ الاختبار';
COMMENT ON COLUMN hr.employee_reading_levels.expiry_date IS 'تاريخ انتهاء الصلاحية';

-- رسالة تأكيد
SELECT '✅ Table employee_reading_levels created successfully' AS status;