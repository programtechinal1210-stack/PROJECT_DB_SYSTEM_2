 
-- =============================================
-- FILE: structure/field/Views/v_location_details.sql
-- PURPOSE: عرض تفاصيل المواقع مع معلومات إضافية
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW field.v_location_details AS
SELECT 
    l.location_id,
    l.location_code,
    l.location_name_ar,
    l.location_name_en,
    st.type_name_ar AS site_type,
    tt.type_name_ar AS terrain_type,
    ep.phase_name_ar AS exploration_phase,
    b.branch_name_ar AS responsible_branch,
    l.latitude,
    l.longitude,
    l.elevation,
    l.area_size,
    l.capacity,
    l.status,
    CASE 
        WHEN l.status = 'safe' THEN 'آمن'
        WHEN l.status = 'contested' THEN 'متنازع عليه'
        WHEN l.status = 'dangerous' THEN 'خطير'
        WHEN l.status = 'unstable' THEN 'غير مستقر'
        WHEN l.status = 'restricted' THEN 'مقيد'
        WHEN l.status = 'closed' THEN 'مغلق'
    END AS status_text,
    l.mineral_potential,
    l.address,
    l.country,
    l.region,
    l.city,
    
    -- إحصائيات
    (SELECT COUNT(*) FROM field.geological_sites WHERE location_id = l.location_id) AS geological_sites_count,
    (SELECT COUNT(*) FROM field.location_facilities WHERE location_id = l.location_id) AS facilities_count,
    (SELECT COUNT(*) FROM field.tasks WHERE location_id = l.location_id AND status IN ('scheduled', 'in_progress')) AS active_tasks_count,
    (SELECT COUNT(*) FROM field.exploration_materials WHERE location_id = l.location_id) AS materials_count,
    
    l.created_at,
    l.updated_at
FROM field.locations l
LEFT JOIN field.site_types st ON l.site_type_id = st.type_id
LEFT JOIN field.terrain_types tt ON l.terrain_type_id = tt.type_id
LEFT JOIN field.exploration_phases ep ON l.exploration_phase_id = ep.phase_id
LEFT JOIN organization.branches b ON l.branch_id = b.branch_id
ORDER BY l.location_name_ar;

COMMENT ON VIEW field.v_location_details IS 'تفاصيل المواقع مع معلومات إضافية وإحصائيات';

-- رسالة تأكيد
SELECT '✅ View v_location_details created successfully' AS status;