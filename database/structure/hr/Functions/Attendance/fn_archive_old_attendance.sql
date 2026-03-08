 
-- =============================================
-- FILE: structure/hr/Functions/Attendance/fn_archive_old_attendance.sql
-- PURPOSE: دالة أرشفة الحضور القديم
-- SCHEMA: hr
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION hr.fn_archive_old_attendance(
    p_cutoff_date DATE,
    p_dry_run BOOLEAN DEFAULT false
) RETURNS TABLE (
    records_archived INT,
    message TEXT
) AS $$
DECLARE
    v_archived_count INT;
    v_username VARCHAR(100);
BEGIN
    -- الحصول على اسم المستخدم الحالي
    v_username := current_user;
    
    -- التحقق من صحة التاريخ
    IF p_cutoff_date > CURRENT_DATE THEN
        RETURN QUERY SELECT 0, 'لا يمكن أرشفة بيانات مستقبلية';
        RETURN;
    END IF;
    
    IF p_dry_run THEN
        -- فقط حساب عدد السجلات
        SELECT COUNT(*) INTO v_archived_count
        FROM hr.attendance
        WHERE attendance_date < p_cutoff_date;
        
        RETURN QUERY SELECT v_archived_count, 
            format('سيتم أرشفة %s سجل (محاكاة)', v_archived_count);
    ELSE
        -- نسخ البيانات إلى الأرشيف
        WITH archived AS (
            INSERT INTO hr.attendance_archive (
                attendance_id, employee_id, attendance_date,
                attendance_year_month, check_in, check_out, status, notes, created_at, archived_by
            )
            SELECT 
                attendance_id, employee_id, attendance_date,
                attendance_year_month, check_in, check_out, status, notes, created_at, v_username
            FROM hr.attendance
            WHERE attendance_date < p_cutoff_date
            RETURNING attendance_id
        )
        SELECT COUNT(*) INTO v_archived_count FROM archived;
        
        -- حذف البيانات من الجدول الرئيسي
        DELETE FROM hr.attendance WHERE attendance_date < p_cutoff_date;
        
        RETURN QUERY SELECT v_archived_count, 
            format('تم أرشفة %s سجل بنجاح', v_archived_count);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION hr.fn_archive_old_attendance(DATE, BOOLEAN) IS 'أرشفة سجلات الحضور الأقدم من تاريخ محدد';

-- رسالة تأكيد
SELECT '✅ Function fn_archive_old_attendance created successfully' AS status;