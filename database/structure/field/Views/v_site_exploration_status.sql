 
-- =============================================
-- FILE: structure/field/Views/v_site_exploration_status.sql
-- PURPOSE: عرض حالة استكشاف المواقع الجيولوجية
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW field.v_site_exploration_status AS
SELECT 
    gs.site_id,
    gs.site_code,
    gs.site_name_ar,
    gs.site_name_en,
    l.location_name_ar AS location,
    l.region,
    gs.area_size,
    gs.geological_features,
    gs.mineral_deposits,
    gs.estimated_reserves,
    gs.reserve_unit,
    gs.exploration_status,
    CASE 
        WHEN gs.exploration_status = 'studying' THEN 'قيد الدراسة'
        WHEN gs.exploration_status = 'exploring' THEN 'جاري التنقيب'
        WHEN gs.exploration_status = 'completed' THEN 'مكتمل'
        WHEN gs.exploration_status = 'abandoned' THEN 'ملغي'
    END AS status_text,
    gs.discovered_date,
    gs.estimated_value,
    
    -- معلومات إضافية
    ep.phase_name_ar AS current_phase,
    EXTRACT(YEAR FROM age(CURRENT_DATE, gs.discovered_date)) AS years_since_discovery,
    
    gs.created_at,
    gs.updated_at
FROM field.geological_sites gs
JOIN field.locations l ON gs.location_id = l.location_id
LEFT JOIN field.exploration_phases ep ON l.exploration_phase_id = ep.phase_id
ORDER BY 
    CASE gs.exploration_status
        WHEN 'exploring' THEN 1
        WHEN 'studying' THEN 2
        WHEN 'completed' THEN 3
        WHEN 'abandoned' THEN 4
    END, gs.site_name_ar;

COMMENT ON VIEW field.v_site_exploration_status IS 'حالة استكشاف المواقع الجيولوجية';

-- رسالة تأكيد
SELECT '✅ View v_site_exploration_status created successfully' AS status;