 
-- =============================================
-- FILE: structure/assets/Views/v_tool_availability.sql
-- PURPOSE: عرض توفر الأدوات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW assets.v_tool_availability AS
SELECT 
    t.tool_id,
    t.tool_code,
    t.tool_name_ar,
    t.serial_number,
    t.category,
    t.status,
    CASE 
        WHEN t.status = 'available' THEN 'متاح'
        WHEN t.status = 'in_use' THEN 'مستعمل'
        WHEN t.status = 'maintenance' THEN 'صيانة'
        WHEN t.status = 'lost' THEN 'مفقود'
        WHEN t.status = 'damaged' THEN 'تالف'
    END AS status_text,
    CASE 
        WHEN ta.assignment_id IS NOT NULL THEN 
            CASE 
                WHEN ta.employee_id IS NOT NULL THEN (SELECT full_name_ar FROM hr.employees WHERE employee_id = ta.employee_id)
                WHEN ta.branch_id IS NOT NULL THEN (SELECT branch_name_ar FROM organization.branches WHERE branch_id = ta.branch_id)
            END
        ELSE NULL
    END AS assigned_to,
    ta.assigned_date,
    ta.expected_return_date,
    t.purchase_date,
    t.warranty_expiry
FROM assets.tools t
LEFT JOIN LATERAL (
    SELECT * FROM assets.tool_assignments 
    WHERE tool_id = t.tool_id AND actual_return_date IS NULL
    ORDER BY assigned_date DESC LIMIT 1
) ta ON true
ORDER BY 
    CASE t.status
        WHEN 'available' THEN 1
        WHEN 'in_use' THEN 2
        WHEN 'maintenance' THEN 3
        ELSE 4
    END, t.tool_name_ar;

COMMENT ON VIEW assets.v_tool_availability IS 'توفر الأدوات والتكليفات الحالية';

-- رسالة تأكيد
SELECT '✅ View v_tool_availability created successfully' AS status;