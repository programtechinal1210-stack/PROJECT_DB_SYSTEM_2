 
-- =============================================
-- FILE: migrations/1.0.0/004-initial-assets-tables.sql
-- VERSION: 1.0.0
-- NAME: initial_assets_tables
-- DESCRIPTION: إنشاء جداول الأصول والمعدات (الآلات، الأدوات، الموارد)
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
    
    IF migrations.is_migration_applied('1.0.0', 'initial_assets_tables') THEN
        RAISE NOTICE 'Migration 1.0.0 - initial_assets_tables already applied';
        RETURN;
    END IF;
    
    -- ============================================
    -- 1. إنشاء الأنواع المخصصة (ENUMs)
    -- ============================================
    
    -- حالة الآلة
    DO $$ BEGIN
        CREATE TYPE assets.machine_status AS ENUM ('active', 'inactive', 'stored', 'maintenance');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالة الأداة
    DO $$ BEGIN
        CREATE TYPE assets.tool_status AS ENUM ('available', 'in_use', 'maintenance', 'lost', 'damaged');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالة المعدات
    DO $$ BEGIN
        CREATE TYPE assets.equipment_condition AS ENUM ('good', 'damaged', 'missing');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- ============================================
    -- 2. إنشاء جداول الـ Lookup
    -- ============================================
    
    -- أنواع الآلات
    CREATE TABLE IF NOT EXISTS assets.machine_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(50) UNIQUE NOT NULL,
        type_name_ar VARCHAR(255) NOT NULL,
        type_name_en VARCHAR(255),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- حالات الآلات
    CREATE TABLE IF NOT EXISTS assets.machine_statuses (
        status_id SERIAL PRIMARY KEY,
        status_code VARCHAR(50) UNIQUE NOT NULL,
        status_name_ar VARCHAR(100) NOT NULL,
        status_name_en VARCHAR(100)
    );

    -- أنواع الموارد
    CREATE TABLE IF NOT EXISTS assets.resource_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(50) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- أنواع الأجهزة
    CREATE TABLE IF NOT EXISTS assets.device_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(50) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- ============================================
    -- 3. إنشاء الجداول الرئيسية
    -- ============================================
    
    -- جدول الآلات
    CREATE TABLE IF NOT EXISTS assets.machines (
        machine_id SERIAL PRIMARY KEY,
        machine_code VARCHAR(50) UNIQUE NOT NULL,
        machine_name_ar VARCHAR(255) NOT NULL,
        machine_name_en VARCHAR(255),
        machine_type_id INT REFERENCES assets.machine_types(type_id),
        serial_number VARCHAR(255) UNIQUE,
        model VARCHAR(100),
        manufacturer VARCHAR(255),
        manufacture_year INT,
        acquisition_date DATE,
        maintenance_interval INT, -- بالأيام
        required_employees INT NOT NULL DEFAULT 1,
        minimum_presence INT NOT NULL DEFAULT 1,
        last_maintenance_date DATE,
        next_maintenance_date DATE GENERATED ALWAYS AS (last_maintenance_date + (maintenance_interval || ' days')::interval) STORED,
        status_id INT REFERENCES assets.machine_statuses(status_id) DEFAULT 1,
        current_branch_id INT REFERENCES organization.branches(branch_id),
        current_branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id),
        current_branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        version INT DEFAULT 1,
        
        CONSTRAINT chk_manufacture_year CHECK (manufacture_year BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE) + 5)
    );

    -- جدول الأدوات
    CREATE TABLE IF NOT EXISTS assets.tools (
        tool_id SERIAL PRIMARY KEY,
        tool_code VARCHAR(50) UNIQUE NOT NULL,
        tool_name_ar VARCHAR(255) NOT NULL,
        tool_name_en VARCHAR(255),
        serial_number VARCHAR(255) UNIQUE,
        category VARCHAR(100),
        manufacturer VARCHAR(255),
        purchase_date DATE,
        warranty_expiry DATE,
        current_value DECIMAL(12,2),
        status assets.tool_status DEFAULT 'available',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id)
    );

    -- جدول الموارد
    CREATE TABLE IF NOT EXISTS assets.resources (
        resource_id SERIAL PRIMARY KEY,
        resource_code VARCHAR(100) UNIQUE NOT NULL,
        resource_name_ar VARCHAR(255) NOT NULL,
        resource_name_en VARCHAR(255),
        type_id INT NOT NULL REFERENCES assets.resource_types(type_id) ON DELETE RESTRICT,
        unit VARCHAR(50),
        minimum_stock DECIMAL(10,2) DEFAULT 0,
        maximum_stock DECIMAL(10,2),
        current_stock DECIMAL(10,2) DEFAULT 0,
        location VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_stock_range CHECK (current_stock >= 0 AND (maximum_stock IS NULL OR current_stock <= maximum_stock))
    );

    -- موارد الآلات
    CREATE TABLE IF NOT EXISTS assets.machine_resources (
        machine_resource_id SERIAL PRIMARY KEY,
        machine_id INT NOT NULL REFERENCES assets.machines(machine_id) ON DELETE CASCADE,
        resource_id INT NOT NULL REFERENCES assets.resources(resource_id) ON DELETE CASCADE,
        quantity DECIMAL(10,2) DEFAULT 0,
        required_quantity DECIMAL(10,2) DEFAULT 0,
        unit VARCHAR(50),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(machine_id, resource_id)
    );

    -- تكليفات الأدوات
    CREATE TABLE IF NOT EXISTS assets.tool_assignments (
        assignment_id SERIAL PRIMARY KEY,
        tool_id INT NOT NULL REFERENCES assets.tools(tool_id) ON DELETE CASCADE,
        employee_id INT REFERENCES hr.employees(employee_id) ON DELETE SET NULL,
        branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
        assigned_by INT REFERENCES core.users(user_id),
        assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
        expected_return_date DATE,
        actual_return_date DATE,
        condition_on_return assets.equipment_condition,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        CONSTRAINT chk_assigned_to CHECK (
            (employee_id IS NOT NULL AND branch_id IS NULL) OR
            (employee_id IS NULL AND branch_id IS NOT NULL)
        ),
        CONSTRAINT chk_return_dates CHECK (actual_return_date IS NULL OR actual_return_date >= assigned_date)
    );

    -- تكليفات الآلات
    CREATE TABLE IF NOT EXISTS assets.machine_assignments (
        assignment_id SERIAL PRIMARY KEY,
        machine_id INT NOT NULL REFERENCES assets.machines(machine_id) ON DELETE CASCADE,
        branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
        branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id) ON DELETE SET NULL,
        branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id) ON DELETE SET NULL,
        assigned_date DATE NOT NULL DEFAULT CURRENT_DATE,
        removed_date DATE,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_machine_assignment CHECK (
            (branch_id IS NOT NULL) OR
            (branch_dept_id IS NOT NULL) OR
            (branch_dept_section_id IS NOT NULL)
        )
    );

    -- جدول الأهداف
    CREATE TABLE IF NOT EXISTS assets.objectives (
        objective_id SERIAL PRIMARY KEY,
        objective_name_ar VARCHAR(255) NOT NULL,
        objective_name_en VARCHAR(255),
        objective_type VARCHAR(100),
        target_value DECIMAL(12,2),
        unit VARCHAR(50),
        period VARCHAR(50),
        start_date DATE,
        end_date DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_objective_dates CHECK (end_date IS NULL OR end_date >= start_date)
    );

    -- أهداف الآلات
    CREATE TABLE IF NOT EXISTS assets.machine_objectives (
        mo_id SERIAL PRIMARY KEY,
        machine_id INT NOT NULL REFERENCES assets.machines(machine_id) ON DELETE CASCADE,
        objective_id INT NOT NULL REFERENCES assets.objectives(objective_id) ON DELETE CASCADE,
        actual_value DECIMAL(12,2),
        achievement_rate DECIMAL(6,2),
        measurement_date DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        UNIQUE(machine_id, objective_id, measurement_date)
    );

    -- معدات الأجهزة المطلوبة
    CREATE TABLE IF NOT EXISTS assets.device_type_required_equipments (
        id SERIAL PRIMARY KEY,
        type_id INT NOT NULL REFERENCES assets.device_types(type_id) ON DELETE CASCADE,
        equipment_name_ar VARCHAR(100) NOT NULL,
        equipment_name_en VARCHAR(100),
        specs TEXT,
        is_required BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- أجهزة الاتصال
    CREATE TABLE IF NOT EXISTS assets.communication_devices (
        device_id SERIAL PRIMARY KEY,
        device_code VARCHAR(50) UNIQUE NOT NULL,
        device_name_ar VARCHAR(255) NOT NULL,
        device_name_en VARCHAR(255),
        serial_number VARCHAR(100) UNIQUE NOT NULL,
        type_id INT NOT NULL REFERENCES assets.device_types(type_id),
        machine_id INT REFERENCES assets.machines(machine_id) ON DELETE SET NULL,
        employee_id INT REFERENCES hr.employees(employee_id) ON DELETE SET NULL,
        status VARCHAR(20) DEFAULT 'active',
        purchase_date DATE,
        warranty_expiry DATE,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_device_status CHECK (status IN ('active', 'inactive', 'maintenance'))
    );

    -- المعدات الفعلية للأجهزة
    CREATE TABLE IF NOT EXISTS assets.actual_device_equipments (
        id SERIAL PRIMARY KEY,
        device_id INT NOT NULL REFERENCES assets.communication_devices(device_id) ON DELETE CASCADE,
        required_equip_id INT NOT NULL REFERENCES assets.device_type_required_equipments(id) ON DELETE CASCADE,
        serial_number VARCHAR(100),
        condition assets.equipment_condition DEFAULT 'good',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        UNIQUE(device_id, required_equip_id)
    );

    -- Outbox للرسائل
    CREATE TABLE IF NOT EXISTS assets.outbox_messages (
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

    -- Inbox للرسائل
    CREATE TABLE IF NOT EXISTS assets.inbox_messages (
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
    CREATE INDEX IF NOT EXISTS idx_machines_code ON assets.machines(machine_code);
    CREATE INDEX IF NOT EXISTS idx_machines_status ON assets.machines(status_id);
    CREATE INDEX IF NOT EXISTS idx_machines_branch ON assets.machines(current_branch_id);
    CREATE INDEX IF NOT EXISTS idx_machines_next_maintenance ON assets.machines(next_maintenance_date) WHERE status_id = 1;
    
    CREATE INDEX IF NOT EXISTS idx_tools_code ON assets.tools(tool_code);
    CREATE INDEX IF NOT EXISTS idx_tools_status ON assets.tools(status);
    CREATE INDEX IF NOT EXISTS idx_tools_serial ON assets.tools(serial_number);
    
    CREATE INDEX IF NOT EXISTS idx_resources_code ON assets.resources(resource_code);
    CREATE INDEX IF NOT EXISTS idx_resources_type ON assets.resources(type_id);
    CREATE INDEX IF NOT EXISTS idx_resources_stock ON assets.resources(current_stock) WHERE current_stock <= minimum_stock;
    
    CREATE INDEX IF NOT EXISTS idx_machine_resources_machine ON assets.machine_resources(machine_id);
    CREATE INDEX IF NOT EXISTS idx_tool_assignments_employee ON assets.tool_assignments(employee_id) WHERE actual_return_date IS NULL;
    CREATE INDEX IF NOT EXISTS idx_machine_assignments_machine ON assets.machine_assignments(machine_id) WHERE removed_date IS NULL;
    
    CREATE INDEX IF NOT EXISTS idx_comm_devices_serial ON assets.communication_devices(serial_number);
    CREATE INDEX IF NOT EXISTS idx_comm_devices_status ON assets.communication_devices(status);
    
    CREATE INDEX IF NOT EXISTS idx_assets_outbox_status ON assets.outbox_messages(status);
    CREATE INDEX IF NOT EXISTS idx_assets_inbox_status ON assets.inbox_messages(status);

    -- ============================================
    -- 5. إنشاء الدوال المساعدة
    -- ============================================
    
    -- دالة حساب تاريخ الصيانة القادم
    CREATE OR REPLACE FUNCTION assets.calculate_next_maintenance_date(
        p_machine_id INT
    ) RETURNS DATE AS $$
    DECLARE
        v_last_maintenance DATE;
        v_interval INT;
    BEGIN
        SELECT last_maintenance_date, maintenance_interval 
        INTO v_last_maintenance, v_interval
        FROM assets.machines 
        WHERE machine_id = p_machine_id;
        
        IF v_last_maintenance IS NULL OR v_interval IS NULL THEN
            RETURN NULL;
        END IF;
        
        RETURN v_last_maintenance + (v_interval || ' days')::interval;
    END;
    $$ LANGUAGE plpgsql;

    -- دالة التحقق من توفر الأداة
    CREATE OR REPLACE FUNCTION assets.check_tool_availability(
        p_tool_id INT,
        p_check_date DATE DEFAULT CURRENT_DATE
    ) RETURNS BOOLEAN AS $$
    DECLARE
        v_tool_status assets.tool_status;
        v_active_assignment INT;
    BEGIN
        -- الحصول على حالة الأداة
        SELECT status INTO v_tool_status
        FROM assets.tools
        WHERE tool_id = p_tool_id;
        
        IF v_tool_status != 'available' THEN
            RETURN FALSE;
        END IF;
        
        -- التحقق من عدم وجود تكليف نشط
        SELECT COUNT(*) INTO v_active_assignment
        FROM assets.tool_assignments
        WHERE tool_id = p_tool_id
          AND (actual_return_date IS NULL OR actual_return_date > p_check_date);
        
        RETURN v_active_assignment = 0;
    END;
    $$ LANGUAGE plpgsql;

    -- ============================================
    -- 6. إنشاء الـ Triggers
    -- ============================================
    
    DROP TRIGGER IF EXISTS update_machines_updated_at ON assets.machines;
    CREATE TRIGGER update_machines_updated_at 
        BEFORE UPDATE ON assets.machines 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_tools_updated_at ON assets.tools;
    CREATE TRIGGER update_tools_updated_at 
        BEFORE UPDATE ON assets.tools 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_resources_updated_at ON assets.resources;
    CREATE TRIGGER update_resources_updated_at 
        BEFORE UPDATE ON assets.resources 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- Trigger لتحديث تاريخ الصيانة القادم
    CREATE OR REPLACE FUNCTION assets.update_next_maintenance()
    RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.last_maintenance_date IS DISTINCT FROM OLD.last_maintenance_date OR
           NEW.maintenance_interval IS DISTINCT FROM OLD.maintenance_interval THEN
            NEW.next_maintenance_date := assets.calculate_next_maintenance_date(NEW.machine_id);
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS update_machine_maintenance ON assets.machines;
    CREATE TRIGGER update_machine_maintenance
        BEFORE UPDATE ON assets.machines
        FOR EACH ROW
        EXECUTE FUNCTION assets.update_next_maintenance();

    -- ============================================
    -- 7. إدراج البيانات الأساسية
    -- ============================================
    
    -- حالات الآلات
    INSERT INTO assets.machine_statuses (status_code, status_name_ar, status_name_en) VALUES
    ('active', 'نشط', 'Active'),
    ('inactive', 'معطل', 'Inactive'),
    ('stored', 'مخزن', 'Stored'),
    ('maintenance', 'صيانة', 'Maintenance')
    ON CONFLICT (status_code) DO NOTHING;

    -- ============================================
    -- 8. تسجيل المايجريشن
    -- ============================================
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_assets_tables', 
        '004-initial-assets-tables.sql', 
        v_execution_time_ms::INTEGER, 
        true
    );
    
    RAISE NOTICE 'Migration 1.0.0 - initial_assets_tables completed successfully in % ms', v_execution_time_ms;
    
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_assets_tables', 
        '004-initial-assets-tables.sql', 
        v_execution_time_ms::INTEGER, 
        false, 
        v_error_message
    );
    RAISE;
END;
$$;

SELECT '✅ Assets tables migration completed' AS migration_status;