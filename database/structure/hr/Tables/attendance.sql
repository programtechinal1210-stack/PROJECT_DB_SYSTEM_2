 
-- =============================================
-- FILE: structure/hr/Tables/attendance.sql
-- PURPOSE: إنشاء جدول الحضور الرئيسي
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول الحضور
CREATE TABLE IF NOT EXISTS hr.attendance (
    attendance_id BIGSERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES hr.employees(employee_id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    attendance_year_month INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM attendance_date) * 100 + EXTRACT(MONTH FROM attendance_date)) STORED,
    check_in TIME,
    check_out TIME,
    status hr.attendance_status DEFAULT 'present',
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(employee_id, attendance_date),
    
    -- القيود
    CONSTRAINT chk_attendance_times CHECK (check_out IS NULL OR check_out >= check_in)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.attendance IS 'جدول الحضور الرئيسي';
COMMENT ON COLUMN hr.attendance.attendance_id IS 'المعرف الفريد للحضور';
COMMENT ON COLUMN hr.attendance.employee_id IS 'معرف الموظف';
COMMENT ON COLUMN hr.attendance.attendance_date IS 'تاريخ الحضور';
COMMENT ON COLUMN hr.attendance.attendance_year_month IS 'سنة وشهر الحضور (للأرشفة)';
COMMENT ON COLUMN hr.attendance.check_in IS 'وقت الحضور';
COMMENT ON COLUMN hr.attendance.check_out IS 'وقت الانصراف';
COMMENT ON COLUMN hr.attendance.status IS 'حالة الحضور';

-- رسالة تأكيد
SELECT '✅ Table attendance created successfully' AS status;