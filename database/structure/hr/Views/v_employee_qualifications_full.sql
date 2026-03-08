-- =============================================
-- FILE: structure/hr/Views/v_employee_qualifications_full.sql
-- PURPOSE: عرض مؤهلات الموظفين كاملة
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW hr.v_employee_qualifications_full AS
SELECT 
    e.employee_id,
    e.employee_code,
    e.full_name_ar,
    q.qualification_id,
    q.qualification_code,
    q.qualification_name_ar,
    qt.type_name_ar AS qualification_type,
    eq.institution,
    eq.graduation_year,
    eq.grade,
    eq.is_required,
    eq.verified,
    eq.verified_at,
    eq.created_at AS assigned_at
FROM hr.employees e
JOIN hr.employee_qualifications eq ON e.employee_id = eq.employee_id
JOIN hr.qualifications q ON eq.qualification_id = q.qualification_id
LEFT JOIN hr.qualification_types qt ON q.qualification_type_id = qt.type_id
ORDER BY e.full_name_ar, q.qualification_name_ar;

COMMENT ON VIEW hr.v_employee_qualifications_full IS 'عرض مؤهلات الموظفين كاملة';

-- رسالة تأكيد
SELECT '✅ View v_employee_qualifications_full created successfully' AS status;