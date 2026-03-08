 
-- =============================================
-- FILE: migrations/1.0.0/003-initial-hr-tables.sql
-- VERSION: 1.0.0
-- NAME: initial_hr_tables
-- DESCRIPTION: إنشاء جداول الموارد البشرية (الموظفين، المؤهلات، الحضور، التدريب)
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_execution_time_ms INTEGER;
    v_success BOOLEAN := true;
    v_error_message TEXT := NULL;
BEGIN
    v_start_time := clock_timestamp();
    
    IF migrations.is_migration_applied('1.0.0', 'initial_hr_tables') THEN
        RAISE NOTICE 'Migration 1.0.0 - initial_hr_tables already applied';
        RETURN;
    END IF;
    
    -- ============================================
    -- 1. إنشاء الأنواع المخصصة (ENUMs)
    -- ============================================
    
    -- حالة الحضور
    DO $$ BEGIN
        CREATE TYPE hr.attendance_status AS ENUM ('present', 'absent', 'vacation', 'sick', 'late', 'permission');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالة التدريب
    DO $$ BEGIN
        CREATE TYPE hr.training_status AS ENUM ('enrolled', 'completed', 'failed', 'withdrawn');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالة الموظف
    DO $$ BEGIN
        CREATE TYPE hr.employee_status AS ENUM ('active', 'vacation', 'sick', 'terminated', 'retired');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- نوع المؤهل
    DO $$ BEGIN
        CREATE TYPE hr.qualification_type AS ENUM ('educational', 'professional', 'technical', 'certificate');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- ============================================
    -- 2. إنشاء جداول الـ Lookup
    -- ============================================
    
    -- أنواع المؤهلات
    CREATE TABLE IF NOT EXISTS hr.qualification_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(20) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100)
    );

    -- المؤهلات
    CREATE TABLE IF NOT EXISTS hr.qualifications (
        qualification_id SERIAL PRIMARY KEY,
        qualification_code VARCHAR(50) UNIQUE NOT NULL,
        qualification_name_ar VARCHAR(255) NOT NULL,
        qualification_name_en VARCHAR(255),
        qualification_type_id INT REFERENCES hr.qualification_types(type_id),
        description TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id)
    );

    -- الدورات التدريبية
    CREATE TABLE IF NOT EXISTS hr.training_courses (
        course_id SERIAL PRIMARY KEY,
        course_code VARCHAR(50) UNIQUE NOT NULL,
        course_name_ar VARCHAR(255) NOT NULL,
        course_name_en VARCHAR(255),
        category VARCHAR(100),
        duration_days INT,
        provider VARCHAR(255),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id)
    );

    -- مستويات القراءة
    CREATE TABLE IF NOT EXISTS hr.reading_levels (
        reading_level_id SERIAL PRIMARY KEY,
        level_code VARCHAR(20) UNIQUE NOT NULL,
        level_name_ar VARCHAR(255) NOT NULL,
        level_name_en VARCHAR(255),
        min_wpm INT,
        max_wpm INT,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        CONSTRAINT chk_wpm_range CHECK (min_wpm <= max_wpm)
    );

    -- التخصصات الإدارية
    CREATE TABLE IF NOT EXISTS hr.admin_specialties (
        specialty_id SERIAL PRIMARY KEY,
        specialty_code VARCHAR(50) UNIQUE NOT NULL,
        specialty_name_ar VARCHAR(255) NOT NULL,
        specialty_name_en VARCHAR(255),
        field VARCHAR(100),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id)
    );

    -- المستويات الوظيفية
    CREATE TABLE IF NOT EXISTS hr.job_levels (
        level_id SERIAL PRIMARY KEY,
        level_code VARCHAR(50) UNIQUE NOT NULL,
        level_name_ar VARCHAR(255) NOT NULL,
        level_name_en VARCHAR(255),
        description TEXT,
        sort_order INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id)
    );

    -- ============================================
    -- 3. إنشاء الجداول الرئيسية
    -- ============================================
    
    -- جدول الموظفين
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
        reading_level_id INT REFERENCES hr.reading_levels(reading_level_id),
        current_branch_id INT REFERENCES organization.branches(branch_id),
        current_department_id INT REFERENCES organization.departments(department_id),
        current_section_id INT REFERENCES organization.sections(section_id),
        is_active BOOLEAN DEFAULT true,
        employment_status hr.employee_status DEFAULT 'active',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        version INT DEFAULT 1,
        
        CONSTRAINT chk_email_format CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
        CONSTRAINT chk_national_id CHECK (national_id ~ '^[0-9]{10}$')
    );

    -- تكليفات الموظفين
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_assignment_dates CHECK (end_date IS NULL OR end_date >= start_date),
        CONSTRAINT chk_at_least_one_assignment CHECK (
            branch_id IS NOT NULL OR 
            branch_dept_id IS NOT NULL OR 
            branch_dept_section_id IS NOT NULL
        )
    );

    -- مؤهلات الموظفين
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        UNIQUE(employee_id, qualification_id),
        CONSTRAINT chk_graduation_year CHECK (graduation_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE) + 10)
    );

    -- تدريب الموظفين
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_training_score CHECK (score BETWEEN 0 AND 100),
        UNIQUE(employee_id, course_id)
    );

    -- تخصصات الموظفين
    CREATE TABLE IF NOT EXISTS hr.employee_specialties (
        emp_specialty_id SERIAL PRIMARY KEY,
        employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
        specialty_id INT NOT NULL REFERENCES hr.admin_specialties(specialty_id) ON DELETE CASCADE,
        is_required BOOLEAN DEFAULT true,
        completion_date DATE,
        score DECIMAL(5,2),
        status hr.training_status DEFAULT 'enrolled',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(employee_id, specialty_id)
    );

    -- المستويات الوظيفية للموظفين
    CREATE TABLE IF NOT EXISTS hr.employee_job_levels (
        emp_level_id SERIAL PRIMARY KEY,
        employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
        level_id INT NOT NULL REFERENCES hr.job_levels(level_id) ON DELETE CASCADE,
        is_required BOOLEAN DEFAULT true,
        start_date DATE NOT NULL,
        end_date DATE,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(employee_id, level_id, start_date)
    );

    -- مستويات القراءة للموظفين
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
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_reading_score CHECK (score BETWEEN 0 AND 100)
    );

    -- جدول الحضور الرئيسي
    CREATE TABLE IF NOT EXISTS hr.attendance (
        attendance_id BIGSERIAL PRIMARY KEY,
        employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
        attendance_date DATE NOT NULL,
        attendance_year_month INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM attendance_date) * 100 + EXTRACT(MONTH FROM attendance_date)) STORED,
        check_in TIME,
        check_out TIME,
        status hr.attendance_status DEFAULT 'present',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(employee_id, attendance_date)
    );

    -- أرشيف الحضور (للبيانات القديمة)
    CREATE TABLE IF NOT EXISTS hr.attendance_archive (
        archive_id BIGSERIAL PRIMARY KEY,
        attendance_id BIGINT,
        employee_id INT NOT NULL,
        attendance_date DATE NOT NULL,
        attendance_year_month INT,
        check_in TIME,
        check_out TIME,
        status hr.attendance_status,
        notes TEXT,
        created_at TIMESTAMP,
        archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Outbox للرسائل
    CREATE TABLE IF NOT EXISTS hr.outbox_messages (
        outbox_id BIGSERIAL PRIMARY KEY,
        message_id UUID DEFAULT gen_random_uuid() UNIQUE,
        message_type VARCHAR(255) NOT NULL,
        aggregate_type VARCHAR(255) NOT NULL,
        aggregate_id BIGINT NOT NULL,
        payload JSONB NOT NULL,
        occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP,
        error TEXT,
        retry_count INT DEFAULT 0,
        status VARCHAR(20) DEFAULT 'pending'
    );

    -- Inbox للرسائل
    CREATE TABLE IF NOT EXISTS hr.inbox_messages (
        inbox_id BIGSERIAL PRIMARY KEY,
        message_id UUID UNIQUE NOT NULL,
        message_type VARCHAR(255) NOT NULL,
        payload JSONB NOT NULL,
        received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP,
        error TEXT,
        status VARCHAR(20) DEFAULT 'pending'
    );

    -- ============================================
    -- 4. إنشاء الفهارس
    -- ============================================
    CREATE INDEX IF NOT EXISTS idx_employees_code ON hr.employees(employee_code);
    CREATE INDEX IF NOT EXISTS idx_employees_name ON hr.employees(full_name_ar);
    CREATE INDEX IF NOT EXISTS idx_employees_national_id ON hr.employees(national_id);
    CREATE INDEX IF NOT EXISTS idx_employees_branch ON hr.employees(current_branch_id);
    CREATE INDEX IF NOT EXISTS idx_employees_status ON hr.employees(is_active, employment_status);
    
    CREATE INDEX IF NOT EXISTS idx_emp_assignments_employee ON hr.employee_assignments(employee_id);
    CREATE INDEX IF NOT EXISTS idx_emp_assignments_dates ON hr.employee_assignments(start_date, end_date);
    CREATE INDEX IF NOT EXISTS idx_emp_assignments_branch ON hr.employee_assignments(branch_id) WHERE branch_id IS NOT NULL;
    
    CREATE INDEX IF NOT EXISTS idx_attendance_date ON hr.attendance(attendance_date);
    CREATE INDEX IF NOT EXISTS idx_attendance_employee_date ON hr.attendance(employee_id, attendance_date);
    CREATE INDEX IF NOT EXISTS idx_attendance_status ON hr.attendance(status);
    CREATE INDEX IF NOT EXISTS idx_attendance_year_month ON hr.attendance(attendance_year_month);
    
    CREATE INDEX IF NOT EXISTS idx_emp_qualifications_employee ON hr.employee_qualifications(employee_id);
    CREATE INDEX IF NOT EXISTS idx_emp_training_employee ON hr.employee_training(employee_id);
    CREATE INDEX IF NOT EXISTS idx_emp_training_dates ON hr.employee_training(completion_date, expiry_date);
    CREATE INDEX IF NOT EXISTS idx_emp_specialties_employee ON hr.employee_specialties(employee_id);
    CREATE INDEX IF NOT EXISTS idx_emp_job_levels_employee ON hr.employee_job_levels(employee_id);
    CREATE INDEX IF NOT EXISTS idx_emp_reading_employee ON hr.employee_reading_levels(employee_id);
    
    CREATE INDEX IF NOT EXISTS idx_hr_outbox_status ON hr.outbox_messages(status);
    CREATE INDEX IF NOT EXISTS idx_hr_inbox_status ON hr.inbox_messages(status);

    -- ============================================
    -- 5. إنشاء الدوال المساعدة
    -- ============================================
    
    -- دالة أرشفة الحضور القديم
    CREATE OR REPLACE FUNCTION hr.archive_old_attendance(p_cutoff_date DATE)
    RETURNS INT AS $$
    DECLARE
        v_archived_count INT;
    BEGIN
        IF p_cutoff_date > CURRENT_DATE THEN
            RAISE EXCEPTION 'لا يمكن أرشفة بيانات مستقبلية';
        END IF;
        
        INSERT INTO hr.attendance_archive (
            attendance_id, employee_id, attendance_date,
            attendance_year_month, check_in, check_out, status, notes, created_at
        )
        SELECT 
            attendance_id, employee_id, attendance_date,
            attendance_year_month, check_in, check_out, status, notes, created_at
        FROM hr.attendance
        WHERE attendance_date < p_cutoff_date;
        
        GET DIAGNOSTICS v_archived_count = ROW_COUNT;
        
        DELETE FROM hr.attendance WHERE attendance_date < p_cutoff_date;
        
        RETURN v_archived_count;
    END;
    $$ LANGUAGE plpgsql;

    -- دالة حساب ساعات الحضور
    CREATE OR REPLACE FUNCTION hr.calculate_attendance_hours(
        p_employee_id INT,
        p_from_date DATE,
        p_to_date DATE
    ) RETURNS TABLE(
        total_days INT,
        present_days INT,
        absent_days INT,
        late_days INT,
        total_hours DECIMAL(10,2)
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            COUNT(*)::INT AS total_days,
            COUNT(*) FILTER (WHERE status = 'present')::INT AS present_days,
            COUNT(*) FILTER (WHERE status = 'absent')::INT AS absent_days,
            COUNT(*) FILTER (WHERE status = 'late')::INT AS late_days,
            COALESCE(SUM(EXTRACT(EPOCH FROM (check_out - check_in))/3600), 0)::DECIMAL(10,2) AS total_hours
        FROM hr.attendance
        WHERE employee_id = p_employee_id
          AND attendance_date BETWEEN p_from_date AND p_to_date;
    END;
    $$ LANGUAGE plpgsql;

    -- ============================================
    -- 6. إنشاء الـ Triggers
    -- ============================================
    
    DROP TRIGGER IF EXISTS update_employees_updated_at ON hr.employees;
    CREATE TRIGGER update_employees_updated_at 
        BEFORE UPDATE ON hr.employees 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_qualifications_updated_at ON hr.qualifications;
    CREATE TRIGGER update_qualifications_updated_at 
        BEFORE UPDATE ON hr.qualifications 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_courses_updated_at ON hr.training_courses;
    CREATE TRIGGER update_courses_updated_at 
        BEFORE UPDATE ON hr.training_courses 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- ============================================
    -- 7. إدراج البيانات الأساسية
    -- ============================================
    
    -- أنواع المؤهلات
    INSERT INTO hr.qualification_types (type_code, type_name_ar, type_name_en) VALUES
    ('educational', 'تعليمي', 'Educational'),
    ('professional', 'مهني', 'Professional'),
    ('technical', 'تقني', 'Technical'),
    ('certificate', 'شهادة', 'Certificate')
    ON CONFLICT (type_code) DO NOTHING;

    -- مستويات القراءة
    INSERT INTO hr.reading_levels (level_code, level_name_ar, min_wpm, max_wpm) VALUES
    ('beginner', 'مبتدئ', 0, 50),
    ('intermediate', 'متوسط', 51, 100),
    ('advanced', 'متقدم', 101, 150),
    ('expert', 'خبير', 151, 999)
    ON CONFLICT (level_code) DO NOTHING;

    -- المستويات الوظيفية
    INSERT INTO hr.job_levels (level_code, level_name_ar, sort_order) VALUES
    ('J1', 'مستوى أول', 1),
    ('J2', 'مستوى ثاني', 2),
    ('J3', 'مستوى ثالث', 3),
    ('J4', 'مستوى رابع', 4),
    ('M1', 'إداري أول', 5),
    ('M2', 'إداري ثاني', 6),
    ('EXEC', 'تنفيذي', 7)
    ON CONFLICT (level_code) DO NOTHING;

    -- ============================================
    -- 8. تسجيل المايجريشن
    -- ============================================
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_hr_tables', 
        '003-initial-hr-tables.sql', 
        v_execution_time_ms::INTEGER, 
        true
    );
    
    RAISE NOTICE 'Migration 1.0.0 - initial_hr_tables completed successfully in % ms', v_execution_time_ms;
    
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_hr_tables', 
        '003-initial-hr-tables.sql', 
        v_execution_time_ms::INTEGER, 
        false, 
        v_error_message
    );
    RAISE;
END;
$$;

SELECT '✅ HR tables migration completed' AS migration_status;