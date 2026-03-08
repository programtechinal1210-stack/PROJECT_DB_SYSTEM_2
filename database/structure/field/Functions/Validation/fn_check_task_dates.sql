 
-- =============================================
-- FILE: structure/field/Functions/Validation/fn_check_task_dates.sql
-- PURPOSE: دالة التحقق من صحة تواريخ المهمة
-- SCHEMA: field
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION field.fn_check_task_dates(
    p_start_date DATE,
    p_end_date DATE,
    p_task_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_conflict_count INT;
BEGIN
    -- التحقق من أن تاريخ البداية ليس في الماضي (للمهام الجديدة)
    IF p_task_id IS NULL AND p_start_date < CURRENT_DATE THEN
        RETURN QUERY SELECT false, 'تاريخ بداية المهمة لا يمكن أن يكون في الماضي';
        RETURN;
    END IF;
    
    -- التحقق من أن تاريخ النهاية بعد تاريخ البداية
    IF p_end_date IS NOT NULL AND p_end_date < p_start_date THEN
        RETURN QUERY SELECT false, 'تاريخ نهاية المهمة يجب أن يكون بعد تاريخ البداية';
        RETURN;
    END IF;
    
    -- التحقق من أن المدة لا تتجاوز حد معقول (مثلاً سنة)
    IF p_end_date IS NOT NULL AND (p_end_date - p_start_date) > 365 THEN
        RETURN QUERY SELECT false, 'مدة المهمة لا يمكن أن تتجاوز سنة واحدة';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'التواريخ صحيحة';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION field.fn_check_task_dates(DATE, DATE, INT) IS 'التحقق من صحة تواريخ المهمة';

-- رسالة تأكيد
SELECT '✅ Function fn_check_task_dates created successfully' AS status;