-- =============================================
-- FILE: seeds/04-assets/001-machine-statuses.sql
-- PURPOSE: إدراج حالات الآلات
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج حالات الآلات
INSERT INTO assets.machine_statuses (
    status_code, 
    status_name_ar, 
    status_name_en
) VALUES
('active', 'نشط', 'Active'),
('inactive', 'معطل', 'Inactive'),
('stored', 'مخزن', 'Stored'),
('maintenance', 'صيانة', 'Maintenance'),
('reserved', 'محجوز', 'Reserved'),
('transferred', 'منقول', 'Transferred'),
('scrapped', 'مستبعد', 'Scrapped')
ON CONFLICT (status_code) DO UPDATE SET
    status_name_ar = EXCLUDED.status_name_ar,
    status_name_en = EXCLUDED.status_name_en;

-- عرض عدد الحالات
SELECT 
    '✅ Machine statuses seeded' AS status,
    COUNT(*) AS total_statuses
FROM assets.machine_statuses;