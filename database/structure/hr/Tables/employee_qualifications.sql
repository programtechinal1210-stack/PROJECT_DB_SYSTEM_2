 
-- =============================================
-- FILE: structure/hr/Tables/employee_qualifications.sql
-- PURPOSE: إنشاء جدول مؤهلات الموظفين
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول مؤهلات الموظفين
CREATE TABLE IF NOT EXISTS hr.employee_qualifications (
    emp_qual_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    qualification_id INT NOT NULL REFERENCES hr.qualifications(qualification_id) ON DELETE CASCADE,
    institution VARCHAR(255),
    is_required BOOLEAN DEFAULT true,
    graduation_year INT,
    grade VARCHAR(50),
    document_url TEXT,
    verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    verified_by INT REFERENCES core.users(user_id),
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(employee_id, qualification_id),
    
    -- القيود
    CONSTRAINT chk_graduation_year CHECK (graduation_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE) + 10)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employee_qualifications IS 'مؤهلات الموظفين';
COMMENT ON COLUMN hr.employee_qualifications.emp_qual_id IS 'المعرف الفريد';
COMMENT ON COLUMN hr.employee_qualifications.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.employee_qualifications.qualification_id IS 'معرف المؤهل';
COMMENT ON COLUMN hr.employee_qualifications.is_required IS 'هل المؤهل مطلوب للوظيفة';
COMMENT ON COLUMN hr.employee_qualifications.verified IS 'هل تم التحقق من المؤهل';

-- رسالة تأكيد
SELECT '✅ Table employee_qualifications created successfully' AS status;