 
-- =============================================
-- FILE: structure/organization/Functions/Validation/fn_validate_branch_code.sql
-- PURPOSE: دالة التحقق من صحة كود الفرع
-- SCHEMA: organization
-- =============================================

\c project_db_system;

CREATE OR REPLACE FUNCTION organization.fn_validate_branch_code(
    p_branch_code VARCHAR,
    p_current_branch_id INT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INT;
BEGIN
    -- التحقق من الطول
    IF LENGTH(p_branch_code) < 2 OR LENGTH(p_branch_code) > 50 THEN
        RETURN QUERY SELECT false, 'كود الفرع يجب أن يكون بين 2 و 50 حرف';
        RETURN;
    END IF;
    
    -- التحقق من الأحرف المسموحة (حروف وأرقام و _ - فقط)
    IF NOT (p_branch_code ~ '^[A-Za-z0-9_-]+$') THEN
        RETURN QUERY SELECT false, 'كود الفرع يمكن أن يحتوي فقط على حروف وأرقام و _ -';
        RETURN;
    END IF;
    
    -- التحقق من عدم التكرار
    SELECT COUNT(*) INTO v_count
    FROM organization.branches
    WHERE branch_code = p_branch_code
      AND (p_current_branch_id IS NULL OR branch_id != p_current_branch_id);
    
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'كود الفرع موجود مسبقاً';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'كود الفرع صالح';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION organization.fn_validate_branch_code(VARCHAR, INT) IS 'التحقق من صحة كود الفرع';

-- رسالة تأكيد
SELECT '✅ Function fn_validate_branch_code created successfully' AS status;