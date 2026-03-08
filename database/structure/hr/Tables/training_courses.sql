 
-- =============================================
-- FILE: structure/hr/Tables/training_courses.sql
-- PURPOSE: إنشاء جدول الدورات التدريبية
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- إنشاء جدول الدورات التدريبية
CREATE TABLE IF NOT EXISTS hr.training_courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(50) UNIQUE NOT NULL,
    course_name_ar VARCHAR(255) NOT NULL,
    course_name_en VARCHAR(255),
    category VARCHAR(100),
    duration_days INT,
    provider VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_duration_positive CHECK (duration_days > 0)
);

-- إضافة تعليقات
COMMENT ON TABLE hr.training_courses IS 'جدول الدورات التدريبية';
COMMENT ON COLUMN hr.training_courses.course_id IS 'المعرف الفريد للدورة';
COMMENT ON COLUMN hr.training_courses.course_code IS 'كود الدورة الفريد';
COMMENT ON COLUMN hr.training_courses.course_name_ar IS 'اسم الدورة بالعربية';
COMMENT ON COLUMN hr.training_courses.course_name_en IS 'اسم الدورة بالإنجليزية';
COMMENT ON COLUMN hr.training_courses.category IS 'تصنيف الدورة';
COMMENT ON COLUMN hr.training_courses.duration_days IS 'مدة الدورة بالأيام';
COMMENT ON COLUMN hr.training_courses.provider IS 'مقدم الدورة';

-- رسالة تأكيد
SELECT '✅ Table training_courses created successfully' AS status;