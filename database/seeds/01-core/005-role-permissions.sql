-- =============================================
-- FILE: seeds/01-core/005-role-permissions.sql
-- PURPOSE: ربط الصلاحيات بالأدوار
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_admin_role_id INT;
    v_hr_role_id INT;
    v_branch_manager_role_id INT;
    v_employee_role_id INT;
    v_viewer_role_id INT;
    v_data_entry_role_id INT;
    v_supervisor_role_id INT;
    v_permission RECORD;
BEGIN
    -- الحصول على معرفات الأدوار
    SELECT role_id INTO v_admin_role_id FROM core.roles WHERE role_code = 'ADMIN';
    SELECT role_id INTO v_hr_role_id FROM core.roles WHERE role_code = 'HR_MANAGER';
    SELECT role_id INTO v_branch_manager_role_id FROM core.roles WHERE role_code = 'BRANCH_MANAGER';
    SELECT role_id INTO v_employee_role_id FROM core.roles WHERE role_code = 'EMPLOYEE';
    SELECT role_id INTO v_viewer_role_id FROM core.roles WHERE role_code = 'VIEWER';
    SELECT role_id INTO v_data_entry_role_id FROM core.roles WHERE role_code = 'DATA_ENTRY';
    SELECT role_id INTO v_supervisor_role_id FROM core.roles WHERE role_code = 'SUPERVISOR';
    
    -- ========================================
    -- 1. صلاحيات ADMIN (جميع الصلاحيات)
    -- ========================================
    FOR v_permission IN SELECT permission_id FROM core.permissions LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_admin_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_admin_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
    -- ========================================
    -- 2. صلاحيات HR_MANAGER
    -- ========================================
    -- صلاحيات الموظفين
    FOR v_permission IN 
        SELECT p.permission_id 
        FROM core.permissions p
        JOIN core.app_modules m ON p.module_id = m.module_id
        WHERE m.module_code IN ('EMPLOYEES', 'ATTENDANCE', 'REPORTS')
        AND p.action_type IN ('view', 'create', 'update', 'export')
    LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_hr_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_hr_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
    -- ========================================
    -- 3. صلاحيات BRANCH_MANAGER
    -- ========================================
    FOR v_permission IN 
        SELECT p.permission_id 
        FROM core.permissions p
        JOIN core.app_modules m ON p.module_id = m.module_id
        WHERE m.module_code IN ('BRANCHES', 'EMPLOYEES', 'ATTENDANCE', 'MACHINES', 'TOOLS', 'TASKS')
        AND p.action_type IN ('view', 'create', 'update')
    LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_branch_manager_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_branch_manager_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
    -- ========================================
    -- 4. صلاحيات EMPLOYEE
    -- ========================================
    FOR v_permission IN 
        SELECT p.permission_id 
        FROM core.permissions p
        JOIN core.app_modules m ON p.module_id = m.module_id
        WHERE m.module_code IN ('DASHBOARD', 'TASKS')
        AND p.action_type IN ('view')
    LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_employee_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_employee_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
    -- إضافة صلاحية عرض الملف الشخصي
    INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
    SELECT v_employee_role_id, p.permission_id, CURRENT_TIMESTAMP
    FROM core.permissions p
    WHERE p.permission_code = 'EMPLOYEES_VIEW'
    AND NOT EXISTS (
        SELECT 1 FROM core.role_permissions 
        WHERE role_id = v_employee_role_id AND permission_id = p.permission_id
    );
    
    -- ========================================
    -- 5. صلاحيات VIEWER
    -- ========================================
    FOR v_permission IN 
        SELECT p.permission_id 
        FROM core.permissions p
        WHERE p.action_type = 'view'
    LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_viewer_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_viewer_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
    -- ========================================
    -- 6. صلاحيات DATA_ENTRY
    -- ========================================
    FOR v_permission IN 
        SELECT p.permission_id 
        FROM core.permissions p
        JOIN core.app_modules m ON p.module_id = m.module_id
        WHERE m.module_code IN ('EMPLOYEES', 'ATTENDANCE', 'MACHINES', 'TOOLS', 'LOCATIONS')
        AND p.action_type IN ('view', 'create', 'update')
    LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_data_entry_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_data_entry_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
    -- ========================================
    -- 7. صلاحيات SUPERVISOR
    -- ========================================
    FOR v_permission IN 
        SELECT p.permission_id 
        FROM core.permissions p
        JOIN core.app_modules m ON p.module_id = m.module_id
        WHERE m.module_code IN ('EMPLOYEES', 'ATTENDANCE', 'TASKS', 'REPORTS')
        AND p.action_type IN ('view', 'create', 'update', 'approve')
    LOOP
        INSERT INTO core.role_permissions (role_id, permission_id, granted_at)
        SELECT v_supervisor_role_id, v_permission.permission_id, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (
            SELECT 1 FROM core.role_permissions 
            WHERE role_id = v_supervisor_role_id AND permission_id = v_permission.permission_id
        );
    END LOOP;
    
END $$;

-- عرض عدد العلاقات
SELECT 
    '✅ Role-permissions seeded' AS status,
    COUNT(*) AS total_assignments
FROM core.role_permissions;