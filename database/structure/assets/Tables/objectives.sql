 
-- =============================================
-- FILE: structure/assets/Tables/objectives.sql
-- PURPOSE: إنشاء جدول الأهداف
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول الأهداف
CREATE TABLE IF NOT EXISTS assets.objectives (
    objective_id SERIAL PRIMARY KEY,
    objective_code VARCHAR(50) UNIQUE NOT NULL,
    objective_name_ar VARCHAR(255) NOT NULL,
    objective_name_en VARCHAR(255),
    objective_type VARCHAR(100),
    description TEXT,
    target_value DECIMAL(12,2),
    unit VARCHAR(50),
    period_type VARCHAR(20), -- daily, weekly, monthly, quarterly, yearly
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_objective_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_period_type CHECK (period_type IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly'))
);

-- إضافة تعليقات
COMMENT ON TABLE assets.objectives IS 'جدول الأهداف';
COMMENT ON COLUMN assets.objectives.objective_id IS 'المعرف الفريد للهدف';
COMMENT ON COLUMN assets.objectives.objective_code IS 'كود الهدف';
COMMENT ON COLUMN assets.objectives.target_value IS 'القيمة المستهدفة';
COMMENT ON COLUMN assets.objectives.period_type IS 'نوع الفترة';

-- رسالة تأكيد
SELECT '✅ Table objectives created successfully' AS status;