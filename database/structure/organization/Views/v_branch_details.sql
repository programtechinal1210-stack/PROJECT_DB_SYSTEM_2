 
-- =============================================
-- FILE: structure/organization/Views/v_branch_details.sql
-- PURPOSE: عرض تفاصيل الفروع مع معلومات إضافية
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW organization.v_branch_details AS
SELECT 
    b.branch_id,
    b.branch_code,
    b.branch_name_ar,
    b.branch_name_en,
    bt.type_name_ar AS branch_type,
    bt.type_code AS branch_type_code,
    os.status_name_ar AS operational_status,
    os.status_code AS operational_status_code,
    b.level,
    b.command_level,
    b.has_departments,
    b.requires_approval,
    b.latitude,
    b.longitude,
    b.address,
    
    -- معلومات الفرع الأب
    p.branch_name_ar AS parent_branch_name,
    p.branch_code AS parent_branch_code,
    
    -- إحصائيات
    (SELECT COUNT(*) FROM organization.branches WHERE parent_branch_id = b.branch_id) AS sub_branches_count,
    (SELECT COUNT(*) FROM organization.branch_departments WHERE branch_id = b.branch_id AND is_active = true) AS active_departments_count,
    (SELECT COUNT(*) FROM organization.branch_departments WHERE branch_id = b.branch_id) AS total_departments_count,
    
    -- معلومات إضافية
    b.notes,
    b.metadata,
    b.created_at,
    b.updated_at,
    u1.username AS created_by_username,
    u2.username AS updated_by_username
FROM organization.branches b
LEFT JOIN organization.branch_types bt ON b.branch_type_id = bt.type_id
LEFT JOIN organization.operational_statuses os ON b.operational_status_id = os.status_id
LEFT JOIN organization.branches p ON b.parent_branch_id = p.branch_id
LEFT JOIN core.users u1 ON b.created_by = u1.user_id
LEFT JOIN core.users u2 ON b.updated_by = u2.user_id;

COMMENT ON VIEW organization.v_branch_details IS 'تفاصيل الفروع مع معلومات إضافية';

-- رسالة تأكيد
SELECT '✅ View v_branch_details created successfully' AS status;