-- =============================================
-- FILE: structure/assets/Indexes/assets_indexes.sql
-- PURPOSE: إنشاء الفهارس المحسنة لجداول assets
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- ============================================
-- فهارس جدول machines
-- ============================================
CREATE INDEX IF NOT EXISTS idx_machines_code ON assets.machines(machine_code);
CREATE INDEX IF NOT EXISTS idx_machines_serial ON assets.machines(serial_number);
CREATE INDEX IF NOT EXISTS idx_machines_type ON assets.machines(machine_type_id);
CREATE INDEX IF NOT EXISTS idx_machines_status ON assets.machines(status_id);
CREATE INDEX IF NOT EXISTS idx_machines_branch ON assets.machines(current_branch_id);
CREATE INDEX IF NOT EXISTS idx_machines_next_maintenance ON assets.machines(next_maintenance_date) WHERE status_id = 1;
CREATE INDEX IF NOT EXISTS idx_machines_acquisition ON assets.machines(acquisition_date);

-- ============================================
-- فهارس جدول tools
-- ============================================
CREATE INDEX IF NOT EXISTS idx_tools_code ON assets.tools(tool_code);
CREATE INDEX IF NOT EXISTS idx_tools_serial ON assets.tools(serial_number);
CREATE INDEX IF NOT EXISTS idx_tools_status ON assets.tools(status);
CREATE INDEX IF NOT EXISTS idx_tools_category ON assets.tools(category);
CREATE INDEX IF NOT EXISTS idx_tools_available ON assets.tools(tool_id) WHERE status = 'available';

-- ============================================
-- فهارس جدول resources
-- ============================================
CREATE INDEX IF NOT EXISTS idx_resources_code ON assets.resources(resource_code);
CREATE INDEX IF NOT EXISTS idx_resources_type ON assets.resources(type_id);
CREATE INDEX IF NOT EXISTS idx_resources_stock ON assets.resources(current_stock) WHERE current_stock <= minimum_stock;
CREATE INDEX IF NOT EXISTS idx_resources_reorder ON assets.resources(resource_id) WHERE current_stock <= reorder_level;

-- ============================================
-- فهارس جدول machine_resources
-- ============================================
CREATE INDEX IF NOT EXISTS idx_machine_resources_machine ON assets.machine_resources(machine_id);
CREATE INDEX IF NOT EXISTS idx_machine_resources_resource ON assets.machine_resources(resource_id);

-- ============================================
-- فهارس جدول machine_assignments
-- ============================================
CREATE INDEX IF NOT EXISTS idx_machine_assignments_machine ON assets.machine_assignments(machine_id);
CREATE INDEX IF NOT EXISTS idx_machine_assignments_active ON assets.machine_assignments(machine_id) WHERE removed_date IS NULL;
CREATE INDEX IF NOT EXISTS idx_machine_assignments_branch ON assets.machine_assignments(branch_id) WHERE removed_date IS NULL;
CREATE INDEX IF NOT EXISTS idx_machine_assignments_dates ON assets.machine_assignments(assigned_date, removed_date);

-- ============================================
-- فهارس جدول tool_assignments
-- ============================================
CREATE INDEX IF NOT EXISTS idx_tool_assignments_tool ON assets.tool_assignments(tool_id);
CREATE INDEX IF NOT EXISTS idx_tool_assignments_employee ON assets.tool_assignments(employee_id) WHERE actual_return_date IS NULL;
CREATE INDEX IF NOT EXISTS idx_tool_assignments_branch ON assets.tool_assignments(branch_id) WHERE actual_return_date IS NULL;
CREATE INDEX IF NOT EXISTS idx_tool_assignments_dates ON assets.tool_assignments(assigned_date, expected_return_date);

-- ============================================
-- فهارس جدول communication_devices
-- ============================================
CREATE INDEX IF NOT EXISTS idx_comm_devices_code ON assets.communication_devices(device_code);
CREATE INDEX IF NOT EXISTS idx_comm_devices_serial ON assets.communication_devices(serial_number);
CREATE INDEX IF NOT EXISTS idx_comm_devices_type ON assets.communication_devices(type_id);
CREATE INDEX IF NOT EXISTS idx_comm_devices_status ON assets.communication_devices(status);
CREATE INDEX IF NOT EXISTS idx_comm_devices_assignment ON assets.communication_devices(machine_id, employee_id);

-- ============================================
-- فهارس جدول maintenance_records
-- ============================================
CREATE INDEX IF NOT EXISTS idx_maintenance_asset ON assets.maintenance_records(asset_type, asset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_dates ON assets.maintenance_records(maintenance_date);
CREATE INDEX IF NOT EXISTS idx_maintenance_type ON assets.maintenance_records(maintenance_type);

-- ============================================
-- فهارس جدول objectives
-- ============================================
CREATE INDEX IF NOT EXISTS idx_objectives_code ON assets.objectives(objective_code);
CREATE INDEX IF NOT EXISTS idx_objectives_type ON assets.objectives(objective_type);
CREATE INDEX IF NOT EXISTS idx_objectives_period ON assets.objectives(period_type);
CREATE INDEX IF NOT EXISTS idx_objectives_dates ON assets.objectives(start_date, end_date);

-- ============================================
-- فهارس جدول machine_objectives
-- ============================================
CREATE INDEX IF NOT EXISTS idx_machine_objectives_machine ON assets.machine_objectives(machine_id);
CREATE INDEX IF NOT EXISTS idx_machine_objectives_date ON assets.machine_objectives(measurement_date);

-- ============================================
-- فهارس outbox/inbox/audit
-- ============================================
CREATE INDEX IF NOT EXISTS idx_assets_outbox_status ON assets.outbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_assets_outbox_occurred ON assets.outbox_messages(occurred_at);
CREATE INDEX IF NOT EXISTS idx_assets_inbox_status ON assets.inbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_assets_audit_table_record ON assets.audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_assets_audit_time ON assets.audit_log(changed_at DESC);

-- رسالة تأكيد
SELECT '✅ Assets indexes created successfully' AS status;