 
-- =============================================
-- FILE: structure/assets/Tables/inbox_messages.sql
-- PURPOSE: إنشاء جدول رسائل Inbox للـ Event-Driven Architecture
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول Inbox للرسائل
CREATE TABLE IF NOT EXISTS assets.inbox_messages (
    inbox_id BIGSERIAL PRIMARY KEY,
    message_id UUID UNIQUE NOT NULL,
    message_type VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    error TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    
    -- القيود
    CONSTRAINT chk_status CHECK (status IN ('pending', 'processing', 'processed', 'failed'))
);

-- إضافة تعليقات
COMMENT ON TABLE assets.inbox_messages IS 'جدول الرسائل الواردة لنمط Inbox';
COMMENT ON COLUMN assets.inbox_messages.inbox_id IS 'المعرف الفريد للرسالة';
COMMENT ON COLUMN assets.inbox_messages.message_id IS 'معرف الرسالة (UUID)';
COMMENT ON COLUMN assets.inbox_messages.message_type IS 'نوع الرسالة';
COMMENT ON COLUMN assets.inbox_messages.payload IS 'محتوى الرسالة';
COMMENT ON COLUMN assets.inbox_messages.received_at IS 'وقت الاستلام';
COMMENT ON COLUMN assets.inbox_messages.status IS 'حالة الرسالة';

-- رسالة تأكيد
SELECT '✅ Table inbox_messages created successfully' AS status;