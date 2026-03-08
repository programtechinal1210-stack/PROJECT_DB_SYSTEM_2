 
-- =============================================
-- FILE: structure/hr/Tables/employees.sql
-- PURPOSE: إنشاء جدول الموظفين
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول الموظفين
CREATE TABLE IF NOT EXISTS hr.employees (
    employee_id SERIAL PRIMARY KEY,
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    full_name_ar VARCHAR(255) NOT NULL,
    full_name_en VARCHAR(255),
    second_name VARCHAR(100),
    national_id VARCHAR(100) UNIQUE,
    fingerprint_id VARCHAR(100) UNIQUE,
    job_title VARCHAR(255),
    emergency_contact VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    birth_date DATE,
    hire_date DATE,
    
    -- المستويات
    reading_level_id INT REFERENCES hr.reading_levels(reading_level_id),
    current_job_level_id INT REFERENCES hr.job_levels(level_id),
    
    -- الموقع الحالي (denormalized for performance)
    current_branch_id INT REFERENCES organization.branches(branch_id),
    current_department_id INT REFERENCES organization.departments(department_id),
    current_section_id INT REFERENCES organization.sections(section_id),
    
    -- الحالة
    is_active BOOLEAN DEFAULT true,
    employment_status hr.employee_status DEFAULT 'active',
    
    -- معلومات إضافية
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_email_format CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_national_id CHECK (national_id IS NULL OR national_id ~ '^[0-9]{10}$'),
    CONSTRAINT chk_phone CHECK (phone IS NULL OR phone ~ '^[0-9+\-\s]+$'),
    CONSTRAINT chk_birth_date CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE),
    CONSTRAINT chk_hire_date CHECK (hire_date IS NULL OR hire_date <= CURRENT_DATE)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.employees IS 'جدول الموظفين';
COMMENT ON COLUMN hr.employees.employee_id IS 'المعرف الفريد للموظف';
COMMENT ON COLUMN hr.employees.employee_code IS 'كود الموظف الفريد';
COMMENT ON COLUMN hr.employees.full_name_ar IS 'الاسم الكامل بالعربية';
COMMENT ON COLUMN hr.employees.full_name_en IS 'الاسم الكامل بالإنجليزية';
COMMENT ON COLUMN hr.employees.national_id IS 'رقم الهوية الوطنية';
COMMENT ON COLUMN hr.employees.fingerprint_id IS 'رقم البصمة';
COMMENT ON COLUMN hr.employees.job_title IS 'المسمى الوظيفي';
COMMENT ON COLUMN hr.employees.employment_status IS 'حالة الموظف';
COMMENT ON COLUMN hr.employees.version IS 'رقم الإصدار للتحكم في التزامن';

-- رسالة تأكيد
SELECT '✅ Table employees created successfully' AS status;