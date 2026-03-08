 
-- =============================================
-- FILE: seeds/01-core/001-users.sql
-- PURPOSE: إدراج المستخدمين الأساسيين
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

-- حذف المستخدمين الموجودين (اختياري - للتصحيح فقط)
-- DELETE FROM core.user_roles WHERE user_id IN (SELECT user_id FROM core.users WHERE username IN ('admin', 'hr_manager', 'viewer'));
-- DELETE FROM core.users WHERE username IN ('admin', 'hr_manager', 'viewer');

-- إدراج المستخدمين إذا لم يكونوا موجودين
INSERT INTO core.users (
    username, 
    email, 
    password_hash, 
    user_status, 
    email_verified,
    email_verified_at
)
SELECT 
    'admin', 
    'admin@project.com', 
    crypt('Admin@123', gen_salt('bf')), 
    'active',
    true,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'admin');

INSERT INTO core.users (
    username, 
    email, 
    password_hash, 
    user_status,
    email_verified,
    email_verified_at
)
SELECT 
    'hr_manager', 
    'hr@project.com', 
    crypt('Hr@123', gen_salt('bf')), 
    'active',
    true,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'hr_manager');

INSERT INTO core.users (
    username, 
    email, 
    password_hash, 
    user_status,
    email_verified,
    email_verified_at
)
SELECT 
    'viewer', 
    'viewer@project.com', 
    crypt('View@123', gen_salt('bf')), 
    'active',
    true,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'viewer');

INSERT INTO core.users (
    username, 
    email, 
    password_hash, 
    user_status,
    email_verified
)
SELECT 
    'data_entry', 
    'data@project.com', 
    crypt('Data@123', gen_salt('bf')), 
    'active',
    true
WHERE NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'data_entry');

INSERT INTO core.users (
    username, 
    email, 
    password_hash, 
    user_status,
    email_verified
)
SELECT 
    'branch_manager', 
    'branch@project.com', 
    crypt('Branch@123', gen_salt('bf')), 
    'active',
    true
WHERE NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'branch_manager');

-- عرض عدد المستخدمين المضافين
SELECT 
    '✅ Core users seeded' AS status,
    COUNT(*) AS total_users
FROM core.users;