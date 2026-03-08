-- =============================================
-- FILE: seeds/02-organization/004-operational-statuses.sql
-- PURPOSE: إدراج حالات التشغيل
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج حالات التشغيل
INSERT INTO organization.operational_statuses (
    status_code, 
    status_name_ar, 
    status_name_en, 
    sort_order
) VALUES
('ready', 'جاهز', 'Ready', 1),
('active', 'نشط', 'Active', 2),
('standby', 'احتياط', 'Standby', 3),
('maintenance', 'صيانة', 'Maintenance', 4)
ON CONFLICT (status_code) DO UPDATE SET
    status_name_ar = EXCLUDED.status_name_ar,
    status_name_en = EXCLUDED.status_name_en,
    sort_order = EXCLUDED.sort_order;

-- عرض عدد حالات التشغيل
SELECT 
    '✅ Operational statuses seeded' AS status,
    COUNT(*) AS total_statuses
FROM organization.operational_statuses;