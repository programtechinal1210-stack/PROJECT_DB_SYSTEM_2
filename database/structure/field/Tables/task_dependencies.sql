-- =============================================
-- FILE: structure/field/Tables/task_dependencies.sql
-- PURPOSE: إنشاء جدول تبعيات المهام
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول تبعيات المهام
CREATE TABLE IF NOT EXISTS field.task_dependencies (
    dependency_id SERIAL PRIMARY KEY,
    task_id INT NOT NULL REFERENCES field.tasks(task_id) ON DELETE CASCADE,
    depends_on_task_id INT NOT NULL REFERENCES field.tasks(task_id) ON DELETE CASCADE,
    dependency_type VARCHAR(20) DEFAULT 'finish_to_start',
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(task_id, depends_on_task_id),
    
    -- منع الاعتماد على النفس
    CONSTRAINT chk_no_self_dependency CHECK (task_id != depends_on_task_id),
    
    -- القيود
    CONSTRAINT chk_dependency_type CHECK (dependency_type IN ('finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish'))
);

-- إضافة تعليقات
COMMENT ON TABLE field.task_dependencies IS 'تبعيات المهام';
COMMENT ON COLUMN field.task_dependencies.dependency_id IS 'المعرف الفريد للتبعية';
COMMENT ON COLUMN field.task_dependencies.task_id IS 'المهمة التابعة';
COMMENT ON COLUMN field.task_dependencies.depends_on_task_id IS 'المهمة التي تعتمد عليها';
COMMENT ON COLUMN field.task_dependencies.dependency_type IS 'نوع التبعية';

-- رسالة تأكيد
SELECT '✅ Table task_dependencies created successfully' AS status;