 
-- =============================================
-- FILE: seeds/01-core/004-permissions.sql
-- PURPOSE: إدراج الصلاحيات الأساسية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_module RECORD;
    v_actions TEXT[] := ARRAY['VIEW', 'CREATE', 'UPDATE', 'DELETE', 'EXPORT', 'IMPORT', 'APPROVE', 'REJECT'];
    v_action_text TEXT;
    v_action_lower TEXT;
    v_permission_code TEXT;
    v_permission_name_ar TEXT;
BEGIN
    -- إنشاء الصلاحيات لكل وحدة
    FOR v_module IN 
        SELECT module_id, module_code, module_name_ar 
        FROM core.app_modules 
        WHERE is_active = true
    LOOP
        FOREACH v_action_text IN ARRAY v_actions LOOP
            v_action_lower := lower(v_action_text);
            v_permission_code := v_module.module_code || '_' || v_action_text;
            
            -- تحديد اسم الصلاحية بالعربية
            v_permission_name_ar := CASE v_action_text
                WHEN 'VIEW' THEN 'عرض ' || v_module.module_name_ar
                WHEN 'CREATE' THEN 'إنشاء في ' || v_module.module_name_ar
                WHEN 'UPDATE' THEN 'تعديل في ' || v_module.module_name_ar
                WHEN 'DELETE' THEN 'حذف من ' || v_module.module_name_ar
                WHEN 'EXPORT' THEN 'تصدير ' || v_module.module_name_ar
                WHEN 'IMPORT' THEN 'استيراد إلى ' || v_module.module_name_ar
                WHEN 'APPROVE' THEN 'اعتماد في ' || v_module.module_name_ar
                WHEN 'REJECT' THEN 'رفض في ' || v_module.module_name_ar
                ELSE v_action_text || ' في ' || v_module.module_name_ar
            END;
            
            -- إدراج الصلاحية إذا لم تكن موجودة
            INSERT INTO core.permissions (
                permission_code,
                permission_name_ar,
                permission_name_en,
                permission_description,
                module_id,
                action_type
            )
            SELECT 
                v_permission_code,
                v_permission_name_ar,
                v_action_text || ' ' || v_module.module_name_en,
                'صلاحية ' || v_permission_name_ar,
                v_module.module_id,
                v_action_lower
            WHERE NOT EXISTS (
                SELECT 1 FROM core.permissions 
                WHERE permission_code = v_permission_code
            );
        END LOOP;
    END LOOP;
    
    -- إضافة صلاحيات خاصة
    INSERT INTO core.permissions (
        permission_code,
        permission_name_ar,
        permission_name_en,
        permission_description,
        module_id,
        action_type
    )
    SELECT 
        'SYSTEM_CONFIG',
        'تكوين النظام',
        'System Configuration',
        'تعديل إعدادات النظام',
        m.module_id,
        'configure'
    FROM core.app_modules m
    WHERE m.module_code = 'SETTINGS'
    AND NOT EXISTS (SELECT 1 FROM core.permissions WHERE permission_code = 'SYSTEM_CONFIG');
    
    INSERT INTO core.permissions (
        permission_code,
        permission_name_ar,
        permission_name_en,
        permission_description,
        module_id,
        action_type
    )
    SELECT 
        'USER_MANAGEMENT',
        'إدارة المستخدمين',
        'User Management',
        'إضافة وتعديل وحذف المستخدمين',
        m.module_id,
        'manage'
    FROM core.app_modules m
    WHERE m.module_code = 'SETTINGS'
    AND NOT EXISTS (SELECT 1 FROM core.permissions WHERE permission_code = 'USER_MANAGEMENT');
    
    INSERT INTO core.permissions (
        permission_code,
        permission_name_ar,
        permission_name_en,
        permission_description,
        module_id,
        action_type
    )
    SELECT 
        'ROLE_MANAGEMENT',
        'إدارة الأدوار',
        'Role Management',
        'إضافة وتعديل وحذف الأدوار',
        m.module_id,
        'manage'
    FROM core.app_modules m
    WHERE m.module_code = 'SETTINGS'
    AND NOT EXISTS (SELECT 1 FROM core.permissions WHERE permission_code = 'ROLE_MANAGEMENT');
    
END $$;

-- عرض عدد الصلاحيات
SELECT 
    '✅ Core permissions seeded' AS status,
    COUNT(*) AS total_permissions
FROM core.permissions;