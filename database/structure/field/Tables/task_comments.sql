-- =============================================
-- FILE: structure/field/Tables/task_comments.sql
-- PURPOSE: إنشاء جدول تعليقات المهام
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول تعليقات المهام
CREATE TABLE IF NOT EXISTS field.task_comments (
    comment_id SERIAL PRIMARY KEY,
    task_id INT NOT NULL REFERENCES field.tasks(task_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES core.users(user_id) ON DELETE SET NULL,
    comment_text TEXT NOT NULL,
    comment_type VARCHAR(20) DEFAULT 'general',
    
    -- معلومات إضافية
    attachments JSONB DEFAULT '[]'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- القيود
    CONSTRAINT chk_comment_type CHECK (comment_type IN ('general', 'progress', 'issue', 'resolution', 'approval'))
);

-- إضافة تعليقات
COMMENT ON TABLE field.task_comments IS 'تعليقات المهام';
COMMENT ON COLUMN field.task_comments.comment_id IS 'المعرف الفريد للتعليق';
COMMENT ON COLUMN field.task_comments.task_id IS 'معرف المهمة';
COMMENT ON COLUMN field.task_comments.user_id IS 'المستخدم';
COMMENT ON COLUMN field.task_comments.comment_type IS 'نوع التعليق';

-- رسالة تأكيد
SELECT '✅ Table task_comments created successfully' AS status;