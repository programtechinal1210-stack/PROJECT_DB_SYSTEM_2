 
-- =============================================
-- FILE: structure/field/Tables/tasks.sql
-- PURPOSE: إنشاء جدول المهام
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء جدول المهام
CREATE TABLE IF NOT EXISTS field.tasks (
    task_id SERIAL PRIMARY KEY,
    task_code VARCHAR(50) UNIQUE NOT NULL,
    task_name_ar VARCHAR(255) NOT NULL,
    task_name_en VARCHAR(255),
    
    -- الربط
    branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    location_id INT REFERENCES field.locations(location_id) ON DELETE SET NULL,
    
    -- تفاصيل المهمة
    description TEXT,
    start_date DATE,
    end_date DATE,
    status field.task_status DEFAULT 'scheduled',
    priority field.task_priority DEFAULT 'medium',
    
    -- معلومات إضافية
    estimated_duration_hours DECIMAL(8,2),
    actual_duration_hours DECIMAL(8,2),
    completion_percentage INT DEFAULT 0,
    
    -- نتائج المهمة
    results TEXT,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    version INT DEFAULT 1,
    
    -- القيود
    CONSTRAINT chk_task_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_completion_percentage CHECK (completion_percentage BETWEEN 0 AND 100),
    CONSTRAINT chk_duration_positive CHECK (estimated_duration_hours IS NULL OR estimated_duration_hours > 0)
);

-- إضافة تعليقات
COMMENT ON TABLE field.tasks IS 'جدول المهام';
COMMENT ON COLUMN field.tasks.task_id IS 'المعرف الفريد للمهمة';
COMMENT ON COLUMN field.tasks.task_code IS 'كود المهمة';
COMMENT ON COLUMN field.tasks.branch_id IS 'الفرع المسؤول';
COMMENT ON COLUMN field.tasks.location_id IS 'الموقع المرتبط';
COMMENT ON COLUMN field.tasks.status IS 'حالة المهمة';
COMMENT ON COLUMN field.tasks.priority IS 'أولوية المهمة';
COMMENT ON COLUMN field.tasks.completion_percentage IS 'نسبة الإنجاز';

-- رسالة تأكيد
SELECT '✅ Table tasks created successfully' AS status;