-- =============================================
-- FILE: structure/field/Indexes/field_indexes.sql
-- PURPOSE: إنشاء الفهارس المحسنة لجداول field
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- ============================================
-- فهارس جدول location_facilities
-- ============================================
CREATE INDEX IF NOT EXISTS idx_facilities_code ON field.location_facilities(facility_code);
CREATE INDEX IF NOT EXISTS idx_facilities_location ON field.location_facilities(location_id);
CREATE INDEX IF NOT EXISTS idx_facilities_type ON field.location_facilities(facility_type_id);
CREATE INDEX IF NOT EXISTS idx_facilities_status ON field.location_facilities(status);
CREATE INDEX IF NOT EXISTS idx_facilities_condition ON field.location_facilities(condition_rating);
CREATE INDEX IF NOT EXISTS idx_facilities_installation ON field.location_facilities(installation_date);

-- ============================================
-- فهارس جدول facility_property_values
-- ============================================
CREATE INDEX IF NOT EXISTS idx_property_values_facility ON field.facility_property_values(facility_id);
CREATE INDEX IF NOT EXISTS idx_property_values_property ON field.facility_property_values(property_id);
CREATE INDEX IF NOT EXISTS idx_property_values_verified ON field.facility_property_values(last_verified);

-- ============================================
-- فهارس جدول tasks
-- ============================================
CREATE INDEX IF NOT EXISTS idx_tasks_code ON field.tasks(task_code);
CREATE INDEX IF NOT EXISTS idx_tasks_branch ON field.tasks(branch_id);
CREATE INDEX IF NOT EXISTS idx_tasks_location ON field.tasks(location_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON field.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON field.tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_dates ON field.tasks(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_tasks_completion ON field.tasks(completion_percentage);
CREATE INDEX IF NOT EXISTS idx_tasks_created ON field.tasks(created_at);

-- ============================================
-- فهارس جدول task_assignments
-- ============================================
CREATE INDEX IF NOT EXISTS idx_task_assignments_task ON field.task_assignments(task_id);
CREATE INDEX IF NOT EXISTS idx_task_assignments_employee ON field.task_assignments(employee_id) WHERE employee_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_task_assignments_machine ON field.task_assignments(machine_id) WHERE machine_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_task_assignments_branch ON field.task_assignments(branch_id) WHERE branch_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_task_assignments_dates ON field.task_assignments(start_date, end_date);

-- ============================================
-- فهارس جدول task_dependencies
-- ============================================
CREATE INDEX IF NOT EXISTS idx_task_dependencies_task ON field.task_dependencies(task_id);
CREATE INDEX IF NOT EXISTS idx_task_dependencies_depends ON field.task_dependencies(depends_on_task_id);
CREATE INDEX IF NOT EXISTS idx_task_dependencies_type ON field.task_dependencies(dependency_type);

-- ============================================
-- فهارس جدول task_comments
-- ============================================
CREATE INDEX IF NOT EXISTS idx_task_comments_task ON field.task_comments(task_id);
CREATE INDEX IF NOT EXISTS idx_task_comments_user ON field.task_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_task_comments_type ON field.task_comments(comment_type);
CREATE INDEX IF NOT EXISTS idx_task_comments_created ON field.task_comments(created_at);

-- ============================================
-- فهارس outbox/inbox/audit
-- ============================================
CREATE INDEX IF NOT EXISTS idx_field_outbox_status ON field.outbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_field_outbox_occurred ON field.outbox_messages(occurred_at);
CREATE INDEX IF NOT EXISTS idx_field_outbox_message_id ON field.outbox_messages(message_id);

CREATE INDEX IF NOT EXISTS idx_field_inbox_status ON field.inbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_field_inbox_received ON field.inbox_messages(received_at);
CREATE INDEX IF NOT EXISTS idx_field_inbox_message_id ON field.inbox_messages(message_id);

CREATE INDEX IF NOT EXISTS idx_field_audit_table_record ON field.audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_field_audit_time ON field.audit_log(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_field_audit_user ON field.audit_log(changed_by);

-- رسالة تأكيد
SELECT '✅ Field indexes created successfully' AS status;