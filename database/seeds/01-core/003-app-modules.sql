-- =============================================
-- FILE: seeds/01-core/003-app-modules.sql
-- PURPOSE: إدراج وحدات التطبيق الأساسية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- إدراج الوحدات الأساسية
INSERT INTO core.app_modules (
    module_code, 
    module_name_ar, 
    module_name_en, 
    module_description, 
    parent_module_id, 
    display_order, 
    icon, 
    route, 
    is_active
) VALUES
('DASHBOARD', 'لوحة التحكم', 'Dashboard', 'لوحة التحكم الرئيسية', NULL, 1, 'dashboard', '/dashboard', true),
('BRANCHES', 'الفروع', 'Branches', 'إدارة الفروع والهيكل التنظيمي', NULL, 2, 'business', '/branches', true),
('EMPLOYEES', 'الموظفين', 'Employees', 'إدارة الموظفين', NULL, 3, 'people', '/employees', true),
('ATTENDANCE', 'الحضور', 'Attendance', 'نظام الحضور والانصراف', NULL, 4, 'schedule', '/attendance', true),
('MACHINES', 'الآلات', 'Machines', 'إدارة الآلات والمعدات', NULL, 5, 'build', '/machines', true),
('TOOLS', 'الأدوات', 'Tools', 'إدارة الأدوات', NULL, 6, 'handyman', '/tools', true),
('LOCATIONS', 'المواقع', 'Locations', 'إدارة المواقع الميدانية', NULL, 7, 'location_on', '/locations', true),
('TASKS', 'المهام', 'Tasks', 'إدارة المهام', NULL, 8, 'task', '/tasks', true),
('REPORTS', 'التقارير', 'Reports', 'التقارير والإحصائيات', NULL, 9, 'assessment', '/reports', true),
('SETTINGS', 'الإعدادات', 'Settings', 'إعدادات النظام', NULL, 10, 'settings', '/settings', true)
ON CONFLICT (module_code) DO UPDATE SET
    module_name_ar = EXCLUDED.module_name_ar,
    module_name_en = EXCLUDED.module_name_en,
    display_order = EXCLUDED.display_order,
    icon = EXCLUDED.icon,
    route = EXCLUDED.route;

-- إضافة وحدات فرعية
INSERT INTO core.app_modules (
    module_code, 
    module_name_ar, 
    module_name_en, 
    module_description, 
    parent_module_id, 
    display_order, 
    icon, 
    route
) 
SELECT 
    'EMPLOYEES_LIST', 
    'قائمة الموظفين', 
    'Employees List', 
    'عرض وإدارة قائمة الموظفين', 
    m.module_id, 
    1, 
    'list', 
    '/employees/list'
FROM core.app_modules m
WHERE m.module_code = 'EMPLOYEES'
AND NOT EXISTS (SELECT 1 FROM core.app_modules WHERE module_code = 'EMPLOYEES_LIST');

INSERT INTO core.app_modules (
    module_code, 
    module_name_ar, 
    module_name_en, 
    module_description, 
    parent_module_id, 
    display_order, 
    icon, 
    route
) 
SELECT 
    'EMPLOYEES_QUALIFICATIONS', 
    'مؤهلات الموظفين', 
    'Employee Qualifications', 
    'إدارة مؤهلات الموظفين', 
    m.module_id, 
    2, 
    'school', 
    '/employees/qualifications'
FROM core.app_modules m
WHERE m.module_code = 'EMPLOYEES'
AND NOT EXISTS (SELECT 1 FROM core.app_modules WHERE module_code = 'EMPLOYEES_QUALIFICATIONS');

INSERT INTO core.app_modules (
    module_code, 
    module_name_ar, 
    module_name_en, 
    module_description, 
    parent_module_id, 
    display_order, 
    icon, 
    route
) 
SELECT 
    'EMPLOYEES_TRAINING', 
    'تدريب الموظفين', 
    'Employee Training', 
    'إدارة تدريب الموظفين', 
    m.module_id, 
    3, 
    'training', 
    '/employees/training'
FROM core.app_modules m
WHERE m.module_code = 'EMPLOYEES'
AND NOT EXISTS (SELECT 1 FROM core.app_modules WHERE module_code = 'EMPLOYEES_TRAINING');

-- عرض عدد الوحدات
SELECT 
    '✅ App modules seeded' AS status,
    COUNT(*) AS total_modules
FROM core.app_modules;