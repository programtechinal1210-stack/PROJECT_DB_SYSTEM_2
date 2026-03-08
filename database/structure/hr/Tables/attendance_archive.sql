 
-- =============================================
-- FILE: structure/hr/Tables/attendance_archive.sql
-- PURPOSE: إنشاء جدول أرشيف الحضور
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول أرشيف الحضور
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
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archived_by VARCHAR(100)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.attendance_archive IS 'أرشيف الحضور (للبيانات القديمة)';
COMMENT ON COLUMN hr.attendance_archive.archive_id IS 'المعرف الفريد للأرشيف';
COMMENT ON COLUMN hr.attendance_archive.attendance_id IS 'المعرف الأصلي في جدول الحضور';
COMMENT ON COLUMN hr.attendance_archive.archived_at IS 'تاريخ الأرشفة';

-- رسالة تأكيد
SELECT '✅ Table attendance_archive created successfully' AS status;