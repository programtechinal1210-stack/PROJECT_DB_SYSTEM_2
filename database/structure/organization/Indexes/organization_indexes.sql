-- =============================================
-- FILE: structure/organization/Indexes/organization_indexes.sql
-- PURPOSE: إنشاء الفهارس المحسنة لجداول organization
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- ============================================
-- فهارس جدول branches
-- ============================================
CREATE INDEX IF NOT EXISTS idx_branches_parent ON organization.branches(parent_branch_id);
CREATE INDEX IF NOT EXISTS idx_branches_level ON organization.branches(level);
CREATE INDEX IF NOT EXISTS idx_branches_code ON organization.branches(branch_code);
CREATE INDEX IF NOT EXISTS idx_branches_status ON organization.branches(operational_status_id);
CREATE INDEX IF NOT EXISTS idx_branches_type ON organization.branches(branch_type_id);
CREATE INDEX IF NOT EXISTS idx_branches_command_level ON organization.branches(command_level);
CREATE INDEX IF NOT EXISTS idx_branches_coordinates ON organization.branches(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_branches_created_at ON organization.branches(created_at);

-- ============================================
-- فهارس جدول branch_closure
-- ============================================
CREATE INDEX IF NOT EXISTS idx_closure_ancestor ON organization.branch_closure(ancestor);
CREATE INDEX IF NOT EXISTS idx_closure_descendant ON organization.branch_closure(descendant);
CREATE INDEX IF NOT EXISTS idx_closure_depth ON organization.branch_closure(depth);
CREATE INDEX IF NOT EXISTS idx_closure_ancestor_descendant ON organization.branch_closure(ancestor, descendant);

-- ============================================
-- فهارس جدول branch_departments
-- ============================================
CREATE INDEX IF NOT EXISTS idx_branch_depts_branch ON organization.branch_departments(branch_id);
CREATE INDEX IF NOT EXISTS idx_branch_depts_dept ON organization.branch_departments(department_id);
CREATE INDEX IF NOT EXISTS idx_branch_depts_active ON organization.branch_departments(is_active);

-- ============================================
-- فهارس جدول branch_dept_sections
-- ============================================
CREATE INDEX IF NOT EXISTS idx_branch_dept_sections_branch_dept ON organization.branch_dept_sections(branch_dept_id);
CREATE INDEX IF NOT EXISTS idx_branch_dept_sections_section ON organization.branch_dept_sections(section_id);
CREATE INDEX IF NOT EXISTS idx_branch_dept_sections_active ON organization.branch_dept_sections(is_active);

-- ============================================
-- فهارس جداول departments و sections
-- ============================================
CREATE INDEX IF NOT EXISTS idx_departments_code ON organization.departments(department_code);
CREATE INDEX IF NOT EXISTS idx_departments_name ON organization.departments(department_name_ar);
CREATE INDEX IF NOT EXISTS idx_sections_code ON organization.sections(section_code);
CREATE INDEX IF NOT EXISTS idx_sections_name ON organization.sections(section_name_ar);

-- ============================================
-- فهارس outbox_messages
-- ============================================
CREATE INDEX IF NOT EXISTS idx_org_outbox_status ON organization.outbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_org_outbox_occurred ON organization.outbox_messages(occurred_at);
CREATE INDEX IF NOT EXISTS idx_org_outbox_message_id ON organization.outbox_messages(message_id);

-- ============================================
-- فهارس inbox_messages
-- ============================================
CREATE INDEX IF NOT EXISTS idx_org_inbox_status ON organization.inbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_org_inbox_received ON organization.inbox_messages(received_at);
CREATE INDEX IF NOT EXISTS idx_org_inbox_message_id ON organization.inbox_messages(message_id);

-- ============================================
-- فهارس audit_log
-- ============================================
CREATE INDEX IF NOT EXISTS idx_org_audit_table_record ON organization.audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_org_audit_time ON organization.audit_log(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_org_audit_user ON organization.audit_log(changed_by);

-- رسالة تأكيد
SELECT '✅ Organization indexes created successfully' AS status;