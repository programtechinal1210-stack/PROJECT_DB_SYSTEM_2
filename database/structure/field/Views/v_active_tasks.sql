 
-- =============================================
-- FILE: structure/field/Views/v_active_tasks.sql
-- PURPOSE: عرض المهام النشطة
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW field.v_active_tasks AS
SELECT 
    t.task_id,
    t.task_code,
    t.task_name_ar,
    t.task_name_en,
    t.description,
    l.location_name_ar AS location,
    b.branch_name_ar AS responsible_branch,
    t.status,
    CASE 
        WHEN t.status = 'scheduled' THEN 'مجدول'
        WHEN t.status = 'in_progress' THEN 'قيد التنفيذ'
        WHEN t.status = 'completed' THEN 'منتهي'
        WHEN t.status = 'cancelled' THEN 'ملغى'
        WHEN t.status = 'on_hold' THEN 'معلق'
        WHEN t.status = 'failed' THEN 'فاشل'
    END AS status_text,
    t.priority,
    CASE 
        WHEN t.priority = 'low' THEN 'منخفض'
        WHEN t.priority = 'medium' THEN 'متوسط'
        WHEN t.priority = 'high' THEN 'عالي'
        WHEN t.priority = 'critical' THEN 'حرج'
    END AS priority_text,
    t.start_date,
    t.end_date,
    t.completion_percentage,
    CASE 
        WHEN t.end_date IS NOT NULL AND t.end_date < CURRENT_DATE AND t.status != 'completed' THEN 'متأخرة'
        WHEN t.end_date IS NOT NULL AND t.end_date <= CURRENT_DATE + INTERVAL '3 days' AND t.status != 'completed' THEN 'تقترب من الموعد'
        ELSE 'في الموعد'
    END AS deadline_status,
    
    -- معلومات التنفيذ
    (SELECT COUNT(*) FROM field.task_assignments WHERE task_id = t.task_id) AS assignees_count,
    (SELECT STRING_AGG(u.username, ', ') 
     FROM field.task_assignments ta 
     LEFT JOIN core.users u ON ta.created_by = u.user_id
     WHERE ta.task_id = t.task_id AND ta.employee_id IS NOT NULL
     LIMIT 3) AS assigned_employees,
    
    t.created_at,
    t.updated_at
FROM field.tasks t
LEFT JOIN field.locations l ON t.location_id = l.location_id
LEFT JOIN organization.branches b ON t.branch_id = b.branch_id
WHERE t.status IN ('scheduled', 'in_progress')
ORDER BY 
    CASE t.priority
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END, t.start_date;

COMMENT ON VIEW field.v_active_tasks IS 'المهام النشطة (قيد التنفيذ والمجدولة)';

-- رسالة تأكيد
SELECT '✅ View v_active_tasks created successfully' AS status;