-- =============================================
-- FILE: structure/core/Indexes/core_indexes.sql
-- PURPOSE: إنشاء الفهارس المحسنة لجداول core
-- SCHEMA: core
-- =============================================

\c project_db_system;

-- ============================================
-- فهارس جدول users
-- ============================================
CREATE INDEX IF NOT EXISTS idx_users_username ON core.users(username) WHERE user_status = 'active';
CREATE INDEX IF NOT EXISTS idx_users_email ON core.users(email);
CREATE INDEX IF NOT EXISTS idx_users_employee ON core.users(employee_id);
CREATE INDEX IF NOT EXISTS idx_users_status ON core.users(user_status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON core.users(created_at);

-- ============================================
-- فهارس جدول user_sessions
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON core.user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_refresh ON core.user_sessions(refresh_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON core.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON core.user_sessions(user_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_user_sessions_expiry ON core.user_sessions(expires_at);

-- ============================================
-- فهارس جدول login_attempts
-- ============================================
CREATE INDEX IF NOT EXISTS idx_login_attempts_username ON core.login_attempts(username);
CREATE INDEX IF NOT EXISTS idx_login_attempts_time ON core.login_attempts(attempt_time DESC);
CREATE INDEX IF NOT EXISTS idx_login_attempts_username_time ON core.login_attempts(username, attempt_time DESC);

-- ============================================
-- فهارس جدول password_resets
-- ============================================
CREATE INDEX IF NOT EXISTS idx_password_resets_token ON core.password_resets(reset_token);
CREATE INDEX IF NOT EXISTS idx_password_resets_user ON core.password_resets(user_id);
CREATE INDEX IF NOT EXISTS idx_password_resets_expiry ON core.password_resets(expires_at);

-- ============================================
-- فهارس جدول audit_log
-- ============================================
CREATE INDEX IF NOT EXISTS idx_audit_log_table_record ON core.audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_time ON core.audit_log(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON core.audit_log(changed_by);
CREATE INDEX IF NOT EXISTS idx_audit_log_operation ON core.audit_log(operation);

-- ============================================
-- فهارس جدول outbox_messages
-- ============================================
CREATE INDEX IF NOT EXISTS idx_outbox_status ON core.outbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_outbox_occurred ON core.outbox_messages(occurred_at);
CREATE INDEX IF NOT EXISTS idx_outbox_message_id ON core.outbox_messages(message_id);

-- ============================================
-- فهارس جدول inbox_messages
-- ============================================
CREATE INDEX IF NOT EXISTS idx_inbox_status ON core.inbox_messages(status);
CREATE INDEX IF NOT EXISTS idx_inbox_received ON core.inbox_messages(received_at);
CREATE INDEX IF NOT EXISTS idx_inbox_message_id ON core.inbox_messages(message_id);

-- رسالة تأكيد
SELECT '✅ Core indexes created successfully' AS status;