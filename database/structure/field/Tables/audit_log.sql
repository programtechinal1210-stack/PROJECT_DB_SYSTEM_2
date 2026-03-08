 
-- =============================================
-- FILE: structure/field/Tables/audit_log.sql
-- PURPOSE: إنشاء جدول سجل التدقيق للـ field
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول سجل التدقيق
CREATE TABLE IF NOT EXISTS field.audit_log (
    audit_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    
    -- القيود
    CONSTRAINT chk_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- إضافة تعليقات
COMMENT ON TABLE field.audit_log IS 'سجل تدقيق التغييرات على جداول field';
COMMENT ON COLUMN field.audit_log.audit_id IS 'المعرف الفريد للسجل';
COMMENT ON COLUMN field.audit_log.table_name IS 'اسم الجدول';
COMMENT ON COLUMN field.audit_log.record_id IS 'معرف السجل';
COMMENT ON COLUMN field.audit_log.operation IS 'نوع العملية';
COMMENT ON COLUMN field.audit_log.old_data IS 'البيانات القديمة';
COMMENT ON COLUMN field.audit_log.new_data IS 'البيانات الجديدة';
COMMENT ON COLUMN field.audit_log.changed_by IS 'اسم المستخدم';

-- رسالة تأكيد
SELECT '✅ Table audit_log created successfully' AS status;