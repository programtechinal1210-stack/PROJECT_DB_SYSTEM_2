-- =============================================
-- FILE: structure/hr/Indexes/hr_indexes.sql
-- PURPOSE: إنشاء الفهارس المحسنة لجداول hr
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- ============================================
-- فهارس جدول employees
-- ============================================
CREATE INDEX IF NOT EXISTS idx_employees_code ON hr.employees(employee_code);
CREATE INDEX IF NOT EXISTS idx_employees_name ON hr.employees(full_name_ar);
CREATE INDEX IF NOT EXISTS idx_employees_national_id ON hr.employees(national_id);
CREATE INDEX IF NOT EXISTS idx_employees_fingerprint ON hr.employees(fingerprint_id);
CREATE INDEX IF NOT EXISTS idx_employees_branch ON hr.employees(current_branch_id);
CREATE INDEX IF NOT EXISTS idx_employees_status ON hr.employees(is_active, employment_status);
CREATE INDEX IF NOT EXISTS idx_employees_hire_date ON hr.employees(hire_date);
CREATE INDEX IF NOT EXISTS idx_employees_birth_date ON hr.employees(birth_date);

-- ============================================
-- فهارس جدول employee_assignments
-- ============================================
CREATE INDEX IF NOT EXISTS idx_emp_assignments_employee ON hr.employee_assignments(employee_id);
CREATE INDEX IF NOT EXISTS idx_emp_assignments_dates ON hr.employee_assignments(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_emp_assignments_branch ON hr.employee_assignments(branch_id) WHERE branch_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_emp_assignments_primary ON hr.employee_assignments(employee_id, is_primary) WHERE is_primary = true;

-- ============================================
-- فهارس جدول attendance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_attendance_date ON hr.attendance(attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_employee_date ON hr.attendance(employee_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON hr.attendance(status);
CREATE INDEX IF NOT EXISTS idx_attendance_year_month ON hr.attendance(attendance_year_month);
CREATE INDEX IF NOT EXISTS idx_attendance_employee_month ON hr.attendance(employee_id, attendance_year_month);
CREATE INDEX IF NOT EXISTS idx_attendance_created_at ON hr.attendance(created_at);

-- ============================================
-- فهارس جدول attendance_archive
-- ============================================
CREATE INDEX IF NOT EXISTS idx_attendance_archive_date ON hr.attendance_archive(attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_archive_ym ON hr.attendance_archive(attendance_year_month);
CREATE INDEX IF NOT EXISTS idx_attendance_archive_archived ON hr.attendance_archive(archived_at);

-- ============================================
-- فهارس جداول المؤهلات والتدريب
-- ============================================
CREATE INDEX IF NOT EXISTS idx_emp_qualifications_employee ON hr.employee_qualifications(employee_id);
CREATE INDEX IF NOT EXISTS idx_emp_qualifications_qualification ON hr.employee_qualifications(qualification_id);
CREATE INDEX IF NOT EXISTS idx_emp_qualifications_verified ON hr.employee_qualifications(verified) WHERE verified = false;

CREATE INDEX IF NOT EXISTS idx_emp_training_employee ON hr.employee_training(employee_id);
CREATE INDEX IF NOT EXISTS idx_emp_training_course ON hr.employee_training(course_id);
CREATE INDEX IF NOT EXISTS idx_emp_training_dates ON hr.employee_training(completion_date, expiry_date);
CREATE INDEX IF NOT EXISTS idx_emp_training_status ON hr.employee_training(status);

CREATE INDEX IF NOT EXISTS idx_emp_specialties_employee ON hr.employee_specialties(employee_id);
CREATE INDEX IF NOT EXISTS idx_emp_specialties_specialty ON hr.employee_specialties(specialty_id);

CREATE INDEX IF NOT EXISTS idx_emp_job_levels_employee ON hr.employee_job_levels(employee_id);
CREATE INDEX IF NOT EXISTS idx_emp_job_levels_dates ON hr.employee_job_levels(start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_emp_reading_employee ON hr.employee_reading_levels(employee_id);
CREATE INDEX IF NOT EXISTS idx_emp_reading_dates ON hr.employee_reading_levels(test_date, expiry_date);

-- ============================================
-- فهارس lookup tables
-- ============================================
CREATE INDEX IF NOT EXISTS idx_qualifications_code ON hr.qualifications(qualification_code);
CREATE INDEX IF NOT EXISTS idx_qualifications_type ON hr.qualifications(qualification_type_id);

CREATE INDEX IF NOT EXISTS idx_training_courses_code ON hr.training_courses(course_code);
CREATE INDEX IF NOT EXISTS idx_training_courses_category ON hr.training_courses(category);

CREATE INDEX IF NOT EXISTS idx_job_levels_code ON hr.job_levels(level_code);
CREATE INDEX IF NOT EXISTS idx_job_levels_order ON hr.job_levels(sort_order);

CREATE INDEX IF NOT EXISTS idx_admin_specialties_code ON hr.admin_specialties(specialty_code);
CREATE INDEX IF NOT EXISTS idx_admin_specialties_field ON hr.admin_specialties(field);

-- ============================================
-- فهارس outbox/inbox/audit
-- ============================================
CREATE INDEX IF NOT EXISTS idx_hr_outbox_status ON hr.outbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_hr_outbox_occurred ON hr.outbox_messages(occurred_at);
CREATE INDEX IF NOT EXISTS idx_hr_outbox_message_id ON hr.outbox_messages(message_id);

CREATE INDEX IF NOT EXISTS idx_hr_inbox_status ON hr.inbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_hr_inbox_received ON hr.inbox_messages(received_at);
CREATE INDEX IF NOT EXISTS idx_hr_inbox_message_id ON hr.inbox_messages(message_id);

CREATE INDEX IF NOT EXISTS idx_hr_audit_table_record ON hr.audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_hr_audit_time ON hr.audit_log(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_hr_audit_user ON hr.audit_log(changed_by);

-- رسالة تأكيد
SELECT '✅ HR indexes created successfully' AS status;