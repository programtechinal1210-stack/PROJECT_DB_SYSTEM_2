 
-- =============================================
-- FILE: structure/hr/Views/v_employee_details.sql
-- PURPOSE: عرض تفاصيل الموظفين مع معلومات إضافية
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW hr.v_employee_details AS
SELECT 
    e.employee_id,
    e.employee_code,
    e.full_name_ar,
    e.full_name_en,
    e.second_name,
    e.national_id,
    e.job_title,
    e.phone,
    e.email,
    e.birth_date,
    e.hire_date,
    e.employment_status,
    
    -- العمر
    EXTRACT(YEAR FROM age(CURRENT_DATE, e.birth_date))::INT AS age,
    EXTRACT(YEAR FROM age(CURRENT_DATE, e.hire_date))::INT AS years_of_service,
    
    -- مستويات
    rl.level_name_ar AS reading_level,
    jl.level_name_ar AS job_level,
    
    -- الموقع الحالي
    b.branch_name_ar AS current_branch,
    d.department_name_ar AS current_department,
    s.section_name_ar AS current_section,
    
    -- إحصائيات
    (SELECT COUNT(*) FROM hr.employee_qualifications WHERE employee_id = e.employee_id) AS qualifications_count,
    (SELECT COUNT(*) FROM hr.employee_training WHERE employee_id = e.employee_id) AS training_count,
    (SELECT COUNT(*) FROM hr.attendance WHERE employee_id = e.employee_id AND attendance_date >= date_trunc('month', CURRENT_DATE)) AS attendance_this_month,
    
    e.is_active,
    e.created_at,
    e.updated_at
FROM hr.employees e
LEFT JOIN hr.reading_levels rl ON e.reading_level_id = rl.reading_level_id
LEFT JOIN hr.job_levels jl ON e.current_job_level_id = jl.level_id
LEFT JOIN organization.branches b ON e.current_branch_id = b.branch_id
LEFT JOIN organization.departments d ON e.current_department_id = d.department_id
LEFT JOIN organization.sections s ON e.current_section_id = s.section_id
WHERE e.is_active = true;

COMMENT ON VIEW hr.v_employee_details IS 'تفاصيل الموظفين مع معلومات إضافية';

-- رسالة تأكيد
SELECT '✅ View v_employee_details created successfully' AS status;