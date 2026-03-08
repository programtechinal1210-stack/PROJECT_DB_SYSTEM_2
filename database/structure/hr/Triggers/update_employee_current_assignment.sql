-- =============================================
-- FILE: structure/hr/Triggers/update_employee_current_assignment.sql
-- PURPOSE: تحديث الموقع الحالي للموظف عند إضافة تكليف جديد
-- SCHEMA: hr
-- =============================================

\c project_db_system;

-- دالة تحديث الموقع الحالي للموظف
CREATE OR REPLACE FUNCTION hr.update_employee_current_location()
RETURNS TRIGGER AS $$
DECLARE
    v_current_assignment RECORD;
BEGIN
    -- إذا كان التكليف الجديد هو التكليف الأساسي أو نشط حالياً
    IF NEW.is_primary OR (NEW.start_date <= CURRENT_DATE AND (NEW.end_date IS NULL OR NEW.end_date >= CURRENT_DATE)) THEN
        -- الحصول على تفاصيل التكليف
        SELECT 
            NEW.branch_id,
            bd.department_id,
            bds.section_id
        INTO v_current_assignment
        FROM (
            SELECT 
                NEW.branch_id,
                NEW.branch_dept_id,
                NEW.branch_dept_section_id
        ) t
        LEFT JOIN organization.branch_departments bd ON t.branch_dept_id = bd.branch_dept_id
        LEFT JOIN organization.branch_dept_sections bds ON t.branch_dept_section_id = bds.branch_dept_section_id;
        
        -- تحديث الموقع الحالي للموظف
        UPDATE hr.employees
        SET 
            current_branch_id = COALESCE(NEW.branch_id, v_current_assignment.branch_id, current_branch_id),
            current_department_id = v_current_assignment.department_id,
            current_section_id = v_current_assignment.section_id,
            updated_at = CURRENT_TIMESTAMP
        WHERE employee_id = NEW.employee_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث الموقع الحالي
DROP TRIGGER IF EXISTS update_employee_location ON hr.employee_assignments;
CREATE TRIGGER update_employee_location
    AFTER INSERT OR UPDATE ON hr.employee_assignments
    FOR EACH ROW
    EXECUTE FUNCTION hr.update_employee_current_location();

-- رسالة تأكيد
SELECT '✅ Employee location update trigger created successfully' AS status;