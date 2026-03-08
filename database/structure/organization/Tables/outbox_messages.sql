 
-- =============================================
-- FILE: structure/organization/Tables/outbox_messages.sql
-- PURPOSE: إنشاء جدول رسائل Outbox للـ Event-Driven Architecture
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول Outbox للرسائل
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
    status VARCHAR(20) DEFAULT 'pending',
    
    -- القيود
    CONSTRAINT chk_status CHECK (status IN ('pending', 'processing', 'processed', 'failed'))
);

-- إضافة تعليقات
COMMENT ON TABLE organization.outbox_messages IS 'جدول الرسائل الصادرة لنمط Outbox';
COMMENT ON COLUMN organization.outbox_messages.outbox_id IS 'المعرف الفريد للرسالة';
COMMENT ON COLUMN organization.outbox_messages.message_id IS 'معرف الرسالة (UUID)';
COMMENT ON COLUMN organization.outbox_messages.message_type IS 'نوع الرسالة';
COMMENT ON COLUMN organization.outbox_messages.aggregate_type IS 'نوع الـ Aggregate';
COMMENT ON COLUMN organization.outbox_messages.aggregate_id IS 'معرف الـ Aggregate';
COMMENT ON COLUMN organization.outbox_messages.payload IS 'محتوى الرسالة';
COMMENT ON COLUMN organization.outbox_messages.occurred_at IS 'وقت حدوث الحدث';
COMMENT ON COLUMN organization.outbox_messages.processed_at IS 'وقت المعالجة';
COMMENT ON COLUMN organization.outbox_messages.status IS 'حالة الرسالة';

-- رسالة تأكيد
SELECT '✅ Table outbox_messages created successfully' AS status;