 
-- =============================================
-- FILE: migrations/1.0.0/005-initial-field-tables.sql
-- VERSION: 1.0.0
-- NAME: initial_field_tables
-- DESCRIPTION: إنشاء جداول المواقع الميدانية (المواقع، المواقع الجيولوجية، المنشآت، المهام)
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
    
    IF migrations.is_migration_applied('1.0.0', 'initial_field_tables') THEN
        RAISE NOTICE 'Migration 1.0.0 - initial_field_tables already applied';
        RETURN;
    END IF;
    
    -- ============================================
    -- 1. إنشاء الأنواع المخصصة (ENUMs)
    -- ============================================
    
    -- أنواع المواقع
    DO $$ BEGIN
        CREATE TYPE field.site_type AS ENUM ('drilling', 'sampling', 'camp', 'warehouse');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- أنواع التضاريس
    DO $$ BEGIN
        CREATE TYPE field.terrain_type AS ENUM ('mountainous', 'coastal', 'desert', 'urban', 'rural');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- مراحل الاستكشاف
    DO $$ BEGIN
        CREATE TYPE field.exploration_phase AS ENUM ('initial', 'exploratory', 'detailed', 'production');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالة الموقع
    DO $$ BEGIN
        CREATE TYPE field.location_status AS ENUM ('safe', 'contested', 'dangerous', 'unstable');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- حالة المهمة
    DO $$ BEGIN
        CREATE TYPE field.task_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- أولوية المهمة
    DO $$ BEGIN
        CREATE TYPE field.task_priority AS ENUM ('low', 'medium', 'high', 'critical');
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END $$;
    
    -- ============================================
    -- 2. إنشاء جداول الـ Lookup
    -- ============================================
    
    -- أنواع المواقع
    CREATE TABLE IF NOT EXISTS field.site_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(50) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100)
    );

    -- أنواع التضاريس
    CREATE TABLE IF NOT EXISTS field.terrain_types (
        type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(50) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100)
    );

    -- مراحل الاستكشاف
    CREATE TABLE IF NOT EXISTS field.exploration_phases (
        phase_id SERIAL PRIMARY KEY,
        phase_code VARCHAR(50) UNIQUE NOT NULL,
        phase_name_ar VARCHAR(100) NOT NULL,
        phase_name_en VARCHAR(100)
    );

    -- أنواع المنشآت
    CREATE TABLE IF NOT EXISTS field.facility_types (
        facility_type_id SERIAL PRIMARY KEY,
        type_code VARCHAR(50) UNIQUE NOT NULL,
        type_name_ar VARCHAR(100) NOT NULL,
        type_name_en VARCHAR(100),
        type_category VARCHAR(50),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- خصائص المنشآت
    CREATE TABLE IF NOT EXISTS field.facility_properties (
        property_id SERIAL PRIMARY KEY,
        facility_type_id INT NOT NULL REFERENCES field.facility_types(facility_type_id) ON DELETE CASCADE,
        property_name_ar VARCHAR(100) NOT NULL,
        property_name_en VARCHAR(100),
        property_type VARCHAR(20) DEFAULT 'text',
        property_unit VARCHAR(50),
        is_required BOOLEAN DEFAULT FALSE,
        min_value DECIMAL(15,3),
        max_value DECIMAL(15,3),
        possible_values JSONB,
        display_order INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        CONSTRAINT chk_property_type CHECK (property_type IN ('numeric', 'text', 'date', 'boolean', 'list'))
    );

    -- ============================================
    -- 3. إنشاء الجداول الرئيسية
    -- ============================================
    
    -- جدول المواقع
    CREATE TABLE IF NOT EXISTS field.locations (
        location_id SERIAL PRIMARY KEY,
        location_code VARCHAR(50) UNIQUE NOT NULL,
        location_name_ar VARCHAR(255) NOT NULL,
        location_name_en VARCHAR(255),
        site_type_id INT REFERENCES field.site_types(type_id),
        terrain_type_id INT REFERENCES field.terrain_types(type_id),
        exploration_phase_id INT REFERENCES field.exploration_phases(phase_id) DEFAULT 1,
        branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
        
        -- الإحداثيات الجغرافية (PostGIS)
        coordinates GEOMETRY(POINT, 4326),
        latitude DECIMAL(10,8) GENERATED ALWAYS AS (ST_Y(coordinates)) STORED,
        longitude DECIMAL(11,8) GENERATED ALWAYS AS (ST_X(coordinates)) STORED,
        
        -- معلومات إضافية
        elevation DECIMAL(8,2),
        area_size DECIMAL(10,2),
        capacity INT,
        
        -- حالة الموقع
        status field.location_status DEFAULT 'safe',
        mineral_potential VARCHAR(20) DEFAULT 'unknown',
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_mineral_potential CHECK (mineral_potential IN ('low', 'medium', 'high', 'unknown'))
    );

    -- المواقع الجيولوجية
    CREATE TABLE IF NOT EXISTS field.geological_sites (
        site_id SERIAL PRIMARY KEY,
        site_code VARCHAR(50) UNIQUE NOT NULL,
        site_name_ar VARCHAR(255) NOT NULL,
        site_name_en VARCHAR(255),
        location_id INT NOT NULL REFERENCES field.locations(location_id) ON DELETE CASCADE,
        area_size DECIMAL(10,2),
        geological_features TEXT,
        mineral_deposits TEXT,
        exploration_status VARCHAR(20) DEFAULT 'studying',
        discovered_date DATE,
        estimated_value DECIMAL(15,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_exploration_status CHECK (exploration_status IN ('studying', 'exploring', 'completed', 'abandoned'))
    );

    -- مواد الاستكشاف
    CREATE TABLE IF NOT EXISTS field.exploration_materials (
        material_id SERIAL PRIMARY KEY,
        material_type VARCHAR(50) NOT NULL,
        material_name_ar VARCHAR(255) NOT NULL,
        material_name_en VARCHAR(255),
        specifications TEXT,
        quantity DECIMAL(10,2) DEFAULT 0,
        unit VARCHAR(50),
        branch_id INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
        location_id INT NOT NULL REFERENCES field.locations(location_id) ON DELETE CASCADE,
        reorder_level DECIMAL(10,2) DEFAULT 100,
        last_restock_date DATE,
        expiry_date DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_material_type CHECK (material_type IN ('drilling_equipment', 'chemicals', 'lab_tools', 'fuel', 'spare_parts'))
    );

    -- منشآت المواقع
    CREATE TABLE IF NOT EXISTS field.location_facilities (
        facility_id SERIAL PRIMARY KEY,
        facility_code VARCHAR(50) UNIQUE NOT NULL,
        facility_name_ar VARCHAR(255) NOT NULL,
        facility_name_en VARCHAR(255),
        location_id INT NOT NULL REFERENCES field.locations(location_id) ON DELETE CASCADE,
        facility_type_id INT NOT NULL REFERENCES field.facility_types(facility_type_id) ON DELETE CASCADE,
        is_required BOOLEAN DEFAULT true,
        status VARCHAR(20) DEFAULT 'planned',
        installation_date DATE,
        capacity DECIMAL(15,3),
        condition_rating VARCHAR(20) DEFAULT 'good',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_facility_status CHECK (status IN ('planned', 'under_construction', 'completed', 'inactive', 'maintenance', 'decommissioned')),
        CONSTRAINT chk_condition_rating CHECK (condition_rating IN ('excellent', 'good', 'fair', 'poor', 'dangerous'))
    );

    -- قيم خصائص المنشآت
    CREATE TABLE IF NOT EXISTS field.facility_property_values (
        value_id SERIAL PRIMARY KEY,
        facility_id INT NOT NULL REFERENCES field.location_facilities(facility_id) ON DELETE CASCADE,
        property_id INT NOT NULL REFERENCES field.facility_properties(property_id) ON DELETE CASCADE,
        numeric_value DECIMAL(15,3),
        text_value TEXT,
        date_value DATE,
        boolean_value BOOLEAN,
        last_verified DATE,
        verified_by INT REFERENCES core.users(user_id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        UNIQUE(facility_id, property_id)
    );

    -- جدول المهام
    CREATE TABLE IF NOT EXISTS field.tasks (
        task_id SERIAL PRIMARY KEY,
        task_code VARCHAR(50) UNIQUE NOT NULL,
        task_name_ar VARCHAR(255) NOT NULL,
        task_name_en VARCHAR(255),
        branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
        description TEXT,
        start_date DATE,
        end_date DATE,
        status field.task_status DEFAULT 'scheduled',
        priority field.task_priority DEFAULT 'medium',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        updated_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_task_dates CHECK (end_date IS NULL OR end_date >= start_date)
    );

    -- تكليفات المهام
    CREATE TABLE IF NOT EXISTS field.task_assignments (
        assignment_id SERIAL PRIMARY KEY,
        task_id INT NOT NULL REFERENCES field.tasks(task_id) ON DELETE CASCADE,
        employee_id INT REFERENCES hr.employees(employee_id) ON DELETE SET NULL,
        machine_id INT REFERENCES assets.machines(machine_id) ON DELETE SET NULL,
        branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
        branch_dept_id INT REFERENCES organization.branch_departments(branch_dept_id) ON DELETE SET NULL,
        branch_dept_section_id INT REFERENCES organization.branch_dept_sections(branch_dept_section_id) ON DELETE SET NULL,
        role VARCHAR(255),
        start_date DATE,
        end_date DATE,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_by BIGINT REFERENCES core.users(user_id),
        
        CONSTRAINT chk_task_assignment_dates CHECK (end_date IS NULL OR end_date >= start_date)
    );

    -- Outbox للرسائل
    CREATE TABLE IF NOT EXISTS field.outbox_messages (
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
    CREATE TABLE IF NOT EXISTS field.inbox_messages (
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
    CREATE INDEX IF NOT EXISTS idx_locations_code ON field.locations(location_code);
    CREATE INDEX IF NOT EXISTS idx_locations_branch ON field.locations(branch_id);
    CREATE INDEX IF NOT EXISTS idx_locations_status ON field.locations(status);
    CREATE INDEX IF NOT EXISTS idx_locations_exploration ON field.locations(exploration_phase_id);
    
    -- فهرس مكاني
    CREATE INDEX IF NOT EXISTS idx_locations_coordinates ON field.locations USING GIST (coordinates);
    
    CREATE INDEX IF NOT EXISTS idx_geological_sites_code ON field.geological_sites(site_code);
    CREATE INDEX IF NOT EXISTS idx_geological_sites_location ON field.geological_sites(location_id);
    CREATE INDEX IF NOT EXISTS idx_geological_sites_status ON field.geological_sites(exploration_status);
    
    CREATE INDEX IF NOT EXISTS idx_facilities_location ON field.location_facilities(location_id);
    CREATE INDEX IF NOT EXISTS idx_facilities_status ON field.location_facilities(status);
    CREATE INDEX IF NOT EXISTS idx_facilities_code ON field.location_facilities(facility_code);
    
    CREATE INDEX IF NOT EXISTS idx_materials_location ON field.exploration_materials(location_id);
    CREATE INDEX IF NOT EXISTS idx_materials_expiry ON field.exploration_materials(expiry_date) WHERE expiry_date IS NOT NULL;
    
    CREATE INDEX IF NOT EXISTS idx_tasks_code ON field.tasks(task_code);
    CREATE INDEX IF NOT EXISTS idx_tasks_status ON field.tasks(status);
    CREATE INDEX IF NOT EXISTS idx_tasks_dates ON field.tasks(start_date, end_date);
    CREATE INDEX IF NOT EXISTS idx_tasks_priority ON field.tasks(priority);
    
    CREATE INDEX IF NOT EXISTS idx_task_assignments_task ON field.task_assignments(task_id);
    CREATE INDEX IF NOT EXISTS idx_task_assignments_employee ON field.task_assignments(employee_id);
    CREATE INDEX IF NOT EXISTS idx_task_assignments_dates ON field.task_assignments(start_date, end_date);
    
    CREATE INDEX IF NOT EXISTS idx_field_outbox_status ON field.outbox_messages(status);
    CREATE INDEX IF NOT EXISTS idx_field_inbox_status ON field.inbox_messages(status);

    -- ============================================
    -- 5. إنشاء الدوال المساعدة
    -- ============================================
    
    -- دالة البحث عن المواقع القريبة
    CREATE OR REPLACE FUNCTION field.find_nearby_locations(
        p_ref_lat DECIMAL,
        p_ref_lng DECIMAL,
        p_radius_km DECIMAL,
        p_site_type_id INT DEFAULT NULL
    ) RETURNS TABLE(
        location_id INT,
        location_name_ar VARCHAR,
        distance_km DECIMAL,
        site_type_name VARCHAR
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            l.location_id,
            l.location_name_ar,
            ST_DistanceSphere(
                l.coordinates, 
                ST_SetSRID(ST_MakePoint(p_ref_lng, p_ref_lat), 4326)
            ) / 1000 AS distance_km,
            st.type_name_ar
        FROM field.locations l
        LEFT JOIN field.site_types st ON l.site_type_id = st.type_id
        WHERE 
            ST_DWithin(
                l.coordinates::geography,
                ST_SetSRID(ST_MakePoint(p_ref_lng, p_ref_lat), 4326)::geography,
                p_radius_km * 1000
            )
            AND (p_site_type_id IS NULL OR l.site_type_id = p_site_type_id)
        ORDER BY distance_km;
    END;
    $$ LANGUAGE plpgsql;

    -- دالة التحقق من سعة الموقع
    CREATE OR REPLACE FUNCTION field.check_location_capacity(
        p_location_id INT
    ) RETURNS TABLE(
        current_count INT,
        max_capacity INT,
        available_spots INT,
        is_available BOOLEAN
    ) AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            COUNT(DISTINCT t.employee_id)::INT AS current_count,
            l.capacity AS max_capacity,
            (l.capacity - COUNT(DISTINCT t.employee_id))::INT AS available_spots,
            (l.capacity > COUNT(DISTINCT t.employee_id)) AS is_available
        FROM field.locations l
        LEFT JOIN field.tasks t ON l.location_id = t.branch_id 
            AND t.status IN ('scheduled', 'in_progress')
        WHERE l.location_id = p_location_id
        GROUP BY l.location_id, l.capacity;
    END;
    $$ LANGUAGE plpgsql;

    -- ============================================
    -- 6. إنشاء الـ Triggers
    -- ============================================
    
    DROP TRIGGER IF EXISTS update_locations_updated_at ON field.locations;
    CREATE TRIGGER update_locations_updated_at 
        BEFORE UPDATE ON field.locations 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_geological_sites_updated_at ON field.geological_sites;
    CREATE TRIGGER update_geological_sites_updated_at 
        BEFORE UPDATE ON field.geological_sites 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_facilities_updated_at ON field.location_facilities;
    CREATE TRIGGER update_facilities_updated_at 
        BEFORE UPDATE ON field.location_facilities 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    DROP TRIGGER IF EXISTS update_tasks_updated_at ON field.tasks;
    CREATE TRIGGER update_tasks_updated_at 
        BEFORE UPDATE ON field.tasks 
        FOR EACH ROW 
        EXECUTE FUNCTION core.update_updated_at_column();

    -- ============================================
    -- 7. إدراج البيانات الأساسية
    -- ============================================
    
    -- أنواع المواقع
    INSERT INTO field.site_types (type_code, type_name_ar, type_name_en) VALUES
    ('drilling', 'موقع حفر', 'Drilling Site'),
    ('sampling', 'منطقة أخذ عينات', 'Sampling Area'),
    ('camp', 'مخيم عمل', 'Work Camp'),
    ('warehouse', 'مستودع معدات', 'Equipment Warehouse')
    ON CONFLICT (type_code) DO NOTHING;

    -- أنواع التضاريس
    INSERT INTO field.terrain_types (type_code, type_name_ar, type_name_en) VALUES
    ('mountainous', 'جبلي', 'Mountainous'),
    ('coastal', 'ساحلي', 'Coastal'),
    ('desert', 'صحراوي', 'Desert'),
    ('urban', 'حضري', 'Urban'),
    ('rural', 'ريفي', 'Rural')
    ON CONFLICT (type_code) DO NOTHING;

    -- مراحل الاستكشاف
    INSERT INTO field.exploration_phases (phase_code, phase_name_ar, phase_name_en) VALUES
    ('initial', 'مسح أولي', 'Initial Survey'),
    ('exploratory', 'حفر استكشافي', 'Exploratory Drilling'),
    ('detailed', 'تقييم مفصل', 'Detailed Assessment'),
    ('production', 'إنتاج', 'Production')
    ON CONFLICT (phase_code) DO NOTHING;

    -- أنواع المنشآت
    INSERT INTO field.facility_types (type_code, type_name_ar, type_name_en, type_category) VALUES
    ('storage', 'غرفة تخزين', 'Storage Room', 'storage'),
    ('tunnel', 'نفق أرضي', 'Underground Tunnel', 'infrastructure'),
    ('admin', 'مبنى إداري', 'Administrative Building', 'building'),
    ('lab', 'معمل', 'Laboratory', 'facility'),
    ('control', 'مركز مراقبة', 'Control Center', 'facility'),
    ('power', 'محطة طاقة', 'Power Station', 'utility'),
    ('security', 'مرفق تأمين', 'Security Facility', 'security')
    ON CONFLICT (type_code) DO NOTHING;

    -- ============================================
    -- 8. تسجيل المايجريشن
    -- ============================================
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_field_tables', 
        '005-initial-field-tables.sql', 
        v_execution_time_ms::INTEGER, 
        true
    );
    
    RAISE NOTICE 'Migration 1.0.0 - initial_field_tables completed successfully in % ms', v_execution_time_ms;
    
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
    v_execution_time_ms := EXTRACT(MILLISECONDS FROM (clock_timestamp() - v_start_time));
    PERFORM migrations.log_migration(
        '1.0.0', 
        'initial_field_tables', 
        '005-initial-field-tables.sql', 
        v_execution_time_ms::INTEGER, 
        false, 
        v_error_message
    );
    RAISE;
END;
$$;

SELECT '✅ Field tables migration completed' AS migration_status;