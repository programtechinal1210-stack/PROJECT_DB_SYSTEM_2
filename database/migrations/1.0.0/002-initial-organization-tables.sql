 
-- =============================================
-- FILE: migrations/1.0.0/002-initial-organization-tables.sql
-- VERSION: 1.0.0
-- NAME: initial_organization_tables
-- DESCRIPTION: إنشاء جداول الهيكل التنظيمي (الفروع، الإدارات، الأقسام)
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_start_time TIMESTAMP;
    v_execution_time_ms INTEGER;
    v_success BOOLEAN := true;
    v_error_message TEXT := NULL;
BEGIN
    v_start_time := clock_timestamp();
    
    IF migrations.is_migration_applied('1.0.0', 'initial_organization_tables') THEN
        RAISE NOTICE 'Migration 1.0.0 - initial_organization_tables already applied';
        RETURN;
    END IF;
    
    -- ============================================
    -- 1. إنشاء الأنواع المخصصة (ENUMs)
    -- ============================================
    
    -- أنواع الفروع
    DO $$ BEGIN
        CREATE TYPE organization.branch_type AS ENUM ('M1', 'M', 'S', 'F');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالات التشغيل
    DO $$ BEGIN
        CREATE TYPE organization.operational_status AS ENUM ('ready', 'active', 'standby', 'maintenance');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- ============================================
    -- 2. إنشاء جداول الـ Lookup
    -- ============================================
    
    -- جدول أنواع الفروع
    CREATE TABLE IF NOT EXISTS organization.branch_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(10) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100),
        sort_order INT DEFAULT 0,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- جدول حالات التشغيل
    CREATE TABLE IF NOT EXISTS organization.operational_statuses (
        status_id SERIAL PRIMARY KEY,
        status_code VARCHAR(20) UNIQUE NOT NULL,
        status_name_ar VARCHAR(100) NOT NULL,
        status_name_en VARCHAR(100),
        sort_order INT DEFAULT 0
    );

    -- ============================================
    -- 3. إنشاء الجداول الرئيسية
    -- ============================================
    
    -- جدول الفروع
    CREATE TABLE IF NOT EXISTS organization.branches (
        branch_id SERIAL PRIMARY KEY,
        branch_code VARCHAR(50) UNIQUE NOT NULL,
        branch_name_ar VARCHAR(255) NOT NULL,
        branch_name_en VARCHAR(255),
        branch_type_id INT REFERENCES organization.branch_types(type_id),
        parent_branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
        level INT NOT NULL DEFAULT 0,
        has_departments BOOLEAN DEFAULT true,
        requires_approval BOOLEAN DEFAULT false,
        position INT DEFAULT 0,
        operational_status_id INT REFERENCES organization.operational_statuses(status_id) DEFAULT 1,
        command_level INT NOT NULL DEFAULT 0,
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        address TEXT,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_parent_not_self CHECK (parent_branch_id IS NULL OR parent_branch_id != branch_id)
    );

    -- Closure Table للهيكل الهرمي
    CREATE TABLE IF NOT EXISTS organization.branch_closure (
        ancestor INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
        descendant INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
        depth INT NOT NULL,
        PRIMARY KEY (ancestor, descendant),
        CONSTRAINT chk_depth_non_negative CHECK (depth >= 0)
    );

    -- جدول الإدارات
    CREATE TABLE IF NOT EXISTS organization.departments (
        department_id SERIAL PRIMARY KEY,
        department_code VARCHAR(50) UNIQUE NOT NULL,
        department_name_ar VARCHAR(255) NOT NULL,
        department_name_en VARCHAR(255),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id)
    );

    -- جدول الأقسام
    CREATE TABLE IF NOT EXISTS organization.sections (
        section_id SERIAL PRIMARY KEY,
        section_code VARCHAR(50) UNIQUE NOT NULL,
        section_name_ar VARCHAR(255) NOT NULL,
        section_name_en VARCHAR(255),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id)
    );

    -- ربط الفروع بالإدارات
    CREATE TABLE IF NOT EXISTS organization.branch_departments (
        branch_dept_id SERIAL PRIMARY KEY,
        branch_id INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
        department_id INT NOT NULL REFERENCES organization.departments(department_id) ON DELETE CASCADE,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(branch_id, department_id)
    );

    -- ربط الفروع-الإدارات بالأقسام
    CREATE TABLE IF NOT EXISTS organization.branch_dept_sections (
        branch_dept_section_id SERIAL PRIMARY KEY,
        branch_dept_id INT NOT NULL REFERENCES organization.branch_departments(branch_dept_id) ON DELETE CASCADE,
        section_id INT NOT NULL REFERENCES organization.sections(section_id) ON DELETE CASCADE,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(branch_dept_id, section_id)
    );

    -- جدول Outbox للرسائل (Event-Driven)
    CREATE TABLE IF NOT EXISTS organization.outbox_messages (
        outbox_id BIGSERIAL PRIMARY KEY,
        message_id UUID DEFAULT gen_random_uuid() UNIQUE,
        message_type VARCHAR(255) NOT NULL,
        aggregate_type VARCHAR(255) NOT NULL,
        aggregate_id BIGINT NOT NULL,
        payload JSONB NOT NULL,
        occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP,
        error TEXT,
        retry_count INT DEFAULT 0,
        status VARCHAR(20) DEFAULT 'pending'
    );

    -- جدول Inbox للرسائل
    CREATE TABLE IF NOT EXISTS organization.inbox_messages (
        inbox_id BIGSERIAL PRIMARY KEY,
        message_id UUID UNIQUE NOT NULL,
        message_type VARCHAR(255) NOT NULL,
        payload JSONB NOT NULL,
        received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP,
        error TEXT,
        status VARCHAR(20) DEFAULT 'pending'
    );

    -- ============================================
    -- 4. إنشاء الفهارس
    -- ============================================
    CREATE INDEX IF NOT EXISTS idx_branches_parent ON organization.branches(parent_branch_id);
    CREATE INDEX IF NOT EXISTS idx_branches_level ON organization.branches(level);
    CREATE INDEX IF NOT EXISTS idx_branches_code ON organization.branches(branch_code);
    CREATE INDEX IF NOT EXISTS idx_branches_status ON organization.branches(operational_status_id);
    CREATE INDEX IF NOT EXISTS idx_branches_type ON organization.branches(branch_type_id);
    
    CREATE INDEX IF NOT EXISTS idx_closure_ancestor ON organization.branch_closure(ancestor);
    CREATE INDEX IF NOT EXISTS idx_closure_descendant ON organization.branch_closure(descendant);
    CREATE INDEX IF NOT EXISTS idx_closure_depth ON organization.branch_closure(depth);
    
    CREATE INDEX IF NOT EXISTS idx_branch_depts_branch ON organization.branch_departments(branch_id);
    CREATE INDEX IF NOT EXISTS idx_branch_depts_dept ON organization.branch_departments(department_id);
    CREATE INDEX IF NOT EXISTS idx_branch_depts_active ON organization.branch_departments(is_active);
    
    CREATE INDEX IF NOT EXISTS idx_branch_dept_sections_branch_dept ON organization.branch_dept_sections(branch_dept_id);
    CREATE INDEX IF NOT EXISTS idx_branch_dept_sections_section ON organization.branch_dept_sections(section_id);
    
    CREATE INDEX IF NOT EXISTS idx_depts_code ON organization.departments(department_code);
    CREATE INDEX IF NOT EXISTS idx_sections_code ON organization.sections(section_code);
    
    CREATE INDEX IF NOT EXISTS idx_org_outbox_status ON organization.outbox_messages(status);
    CREATE INDEX IF NOT EXISTS idx_org_outbox_occurred ON organization.outbox_messages(occurred_at);
    CREATE INDEX IF NOT EXISTS idx_org_inbox_status ON organization.inbox_messages(status);
    CREATE INDEX IF NOT EXISTS idx_org_inbox_message_id ON organization.inbox_messages(message_id);

    -- ============================================
    -- 5. إنشاء الدوال المساعدة
    -- ============================================
    
    -- دالة إضافة فرع جديد
    CREATE OR REPLACE FUNCTION organization.add_branch(
        p_branch_code VARCHAR,
        p_branch_name_ar VARCHAR,
        p_branch_type_id INT,
        p_parent_branch_id INT DEFAULT NULL
    ) RETURNS INT AS $$
    DECLARE
        new_branch_id INT;
        parent_level INT;
    BEGIN
        -- إدراج الفرع الجديد
        INSERT INTO organization.branches (
            branch_code, 
            branch_name_ar, 
            branch_type_id, 
            parent_branch_id, 
            level
        ) VALUES (
            p_branch_code, 
            p_branch_name_ar, 
            p_branch_type_id, 
            p_parent_branch_id, 
            0
        ) RETURNING branch_id INTO new_branch_id;
        
        -- تحديث المستوى إذا كان له والد
        IF p_parent_branch_id IS NOT NULL THEN
            SELECT level INTO parent_level FROM organization.branches WHERE branch_id = p_parent_branch_id;
            UPDATE organization.branches SET level = parent_level + 1 WHERE branch_id = new_branch_id;
        END IF;
        
        -- إضافة العلاقات في Closure Table
        INSERT INTO organization.branch_closure (ancestor, descendant, depth)
        VALUES (new_branch_id, new_branch_id, 0);
        
        IF p_parent_branch_id IS NOT NULL THEN
            INSERT INTO organization.branch_closure (ancestor, descendant, depth)
            SELECT ancestor, new_branch_id, depth + 1
            FROM organization.branch_closure
            WHERE descendant = p_parent_branch_id;
        END IF;
        
        RETURN new_branch_id;
    END;
    $$ LANGUAGE plpgsql;

    -- دالة الحصول على الشجرة الهرمية
    CREATE OR REPLACE FUNCTION organization.get_branch_tree(p_root_branch_id INT DEFAULT NULL)
    RETURNS TABLE(
        branch_id INT,
        branch_name_ar VARCHAR,
        level INT,
        path TEXT,
        has_children BOOLEAN
    ) AS $$
    BEGIN
        RETURN QUERY
        WITH RECURSIVE branch_tree AS (
            SELECT 
                b.branch_id,
                b.branch_name_ar,
                b.level,
                b.branch_id::TEXT AS path,
                EXISTS(SELECT 1 FROM organization.branches WHERE parent_branch_id = b.branch_id) AS has_children
            FROM organization.branches b
            WHERE (p_root_branch_id IS NULL AND b.parent_branch_id IS NULL)
               OR b.branch_id = p_root_branch_id
            
            UNION ALL
            
            SELECT 
                c.branch_id,
                c.branch_name_ar,
                c.level,
                bt.path || '->' || c.branch_id::TEXT,
                EXISTS(SELECT 1 FROM organization.branches WHERE parent_branch_id = c.branch_id)
            FROM organization.branches c
            INNER JOIN branch_tree bt ON c.parent_branch_id = bt.branch_id
        )
        SELECT * FROM branch_tree
        ORDER BY path;
    END;
    $$ LANGUAGE plpgsql;

    -- ============================================
    -- 6. إنشاء الـ Triggers
    -- ============================================
    
    -- Trigger لتحديث updated_at
    DROP TRIGGER IF EXISTS update_branches_updated_at ON organization.branches;
    CREATE TRIGGER update_branches_updated_at 
        BEFORE UPDATE ON organization.branches 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_departments_updated_at ON organization.departments;
    CREATE TRIGGER update_departments_updated_at 
        BEFORE UPDATE ON organization.departments 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_sections_updated_at ON organization.sections;
    CREATE TRIGGER update_sections_updated_at 
        BEFORE UPDATE ON organization.sections 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- ============================================
    -- 7. إدراج البيانات الأساسية
    -- ============================================
    
    -- إدراج أنواع الفروع
    INSERT INTO organization.branch_types (type_code, type_name_ar, type_name_en, sort_order) VALUES
    ('M1', 'فرع رئيسي مستوى 1', 'Main Branch Level 1', 1),
    ('M', 'فرع رئيسي', 'Main Branch', 2),
    ('S', 'فرع فرعي', 'Sub Branch', 3),
    ('F', 'فرع ميداني', 'Field Branch', 4)
    ON CONFLICT (type_code) DO NOTHING;

    -- إدراج حالات التشغيل
    INSERT INTO organization.operational_statuses (status_code, status_name_ar, status_name_en, sort_order) VALUES
    ('ready', 'جاهز', 'Ready', 1),
    ('active', 'نشط', 'Active', 2),
    ('standby', 'احتياط', 'Standby', 3),
    ('maintenance', 'صيانة', 'Maintenance', 4)
    ON CONFLICT (status_code) DO NOTHING;

    -- إدراج الإدارات الأساسية
    INSERT INTO organization.departments (department_code, department_name_ar, department_name_en) VALUES
    ('IT', 'تقنية المعلومات', 'Information Technology'),
    ('HR', 'الموارد البشرية', 'Human Resources'),
    ('FIN', 'المالية', 'Finance'),
    ('OPS', 'العمليات', 'Operations'),
    ('SALES', 'المبيعات', 'Sales'),
    ('LOG', 'اللوجستيات', 'Logistics')
    ON CONFLICT (department_code) DO NOTHING;

    -- إدراج الأقسام الأساسية
    INSERT INTO organization.sections (section_code, section_name_ar, section_name_en) VALUES
    ('DEV', 'التطوير', 'Development'),
    ('SUPPORT', 'الدعم الفني', 'Technical Support'),
    ('RECRUIT', 'التوظيف', 'Recruitment'),
    ('TRAIN', 'التدريب', 'Training'),
    ('ACCOUNT', 'المحاسبة', 'Accounting'),
    ('BUDGET', 'الميزانية', 'Budget')
    ON CONFLICT (section_code) DO NOTHING;

    -- إضافة فرع رئيسي تجريبي
    PERFORM organization.add_branch(
        'HQ', 
        'المركز الرئيسي', 
        (SELECT type_id FROM organization.branch_types WHERE type_code = 'M1')
    );

    -- ============================================
    -- 8. تسجيل المايجريشن
    -- ============================================
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_organization_tables', 
        '002-initial-organization-tables.sql', 
        v_execution_time_ms::INTEGER, 
        true
    );
    
    RAISE NOTICE 'Migration 1.0.0 - initial_organization_tables completed successfully in % ms', v_execution_time_ms;
    
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_organization_tables', 
        '002-initial-organization-tables.sql', 
        v_execution_time_ms::INTEGER, 
        false, 
        v_error_message
    );
    RAISE;
END;
$$;

SELECT '✅ Organization tables migration completed' AS migration_status;