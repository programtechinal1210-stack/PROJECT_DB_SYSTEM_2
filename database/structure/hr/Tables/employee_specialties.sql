 
-- =============================================
-- FILE: structure/hr/Tables/employee_specialties.sql
-- PURPOSE: إنشاء جدول تخصصات الموظفين
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول تخصصات الموظفين
CREATE TABLE IF NOT EXISTS hr.employee_specialties (
    emp_specialty_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    specialty_id INT NOT NULL REFERENCES hr.admin_specialties(specialty_id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT true,
    completion_date DATE,
    score DECIMAL(5,2),
    status hr.training_status DEFAULT 'enrolled',
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(employee_id, specialty_id)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employee_specialties IS 'تخصصات الموظفين';
COMMENT ON COLUMN hr.employee_specialties.emp_specialty_id IS 'المعرف الفريد';
COMMENT ON COLUMN hr.employee_specialties.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.employee_specialties.specialty_id IS 'معرف التخصص';
COMMENT ON COLUMN hr.employee_specialties.is_required IS 'هل التخصص مطلوب';

-- رسالة تأكيد
SELECT '✅ Table employee_specialties created successfully' AS status;