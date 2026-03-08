 
-- =============================================
-- FILE: structure/assets/Tables/machine_objectives.sql
-- PURPOSE: إنشاء جدول أهداف الآلات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء جدول أهداف الآلات
CREATE TABLE IF NOT EXISTS assets.machine_objectives (
    mo_id SERIAL PRIMARY KEY,
    machine_id INT NOT NULL REFERENCES assets.machines(machine_id) ON DELETE CASCADE,
    objective_id INT NOT NULL REFERENCES assets.objectives(objective_id) ON DELETE CASCADE,
    actual_value DECIMAL(12,2),
    achievement_rate DECIMAL(6,2),
    measurement_date DATE,
    notes TEXT,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    
    -- منع التكرار
    UNIQUE(machine_id, objective_id, measurement_date),
    
    -- القيود
    CONSTRAINT chk_achievement_rate CHECK (achievement_rate BETWEEN 0 AND 100)
);

-- إضافة تعليقات
COMMENT ON TABLE assets.machine_objectives IS 'أهداف الآلات وقياس الأداء';
COMMENT ON COLUMN assets.machine_objectives.mo_id IS 'المعرف الفريد';
COMMENT ON COLUMN assets.machine_objectives.machine_id IS 'معرف الآلة';
COMMENT ON COLUMN assets.machine_objectives.objective_id IS 'معرف الهدف';
COMMENT ON COLUMN assets.machine_objectives.actual_value IS 'القيمة الفعلية';
COMMENT ON COLUMN assets.machine_objectives.achievement_rate IS 'نسبة الإنجاز';

-- رسالة تأكيد
SELECT '✅ Table machine_objectives created successfully' AS status;