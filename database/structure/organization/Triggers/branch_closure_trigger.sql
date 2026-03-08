-- =============================================
-- FILE: structure/organization/Triggers/branch_closure_trigger.sql
-- PURPOSE: الحفاظ على اتساق branch_closure عند تغيير parent_branch_id
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- دالة تحديث branch_closure عند تغيير parent_branch_id
CREATE OR REPLACE FUNCTION organization.maintain_branch_closure()
RETURNS TRIGGER AS $$
BEGIN
    -- إذا تغير parent_branch_id
    IF OLD.parent_branch_id IS DISTINCT FROM NEW.parent_branch_id THEN
        -- حذف العلاقات القديمة
        DELETE FROM organization.branch_closure
        WHERE descendant IN (
            SELECT descendant 
            FROM organization.branch_closure 
            WHERE ancestor = NEW.branch_id
        )
        AND ancestor IN (
            SELECT ancestor 
            FROM organization.branch_closure 
            WHERE descendant = NEW.branch_id 
            AND ancestor != descendant
        );
        
        -- إضافة العلاقات الجديدة
        INSERT INTO organization.branch_closure (ancestor, descendant, depth)
        SELECT ancestor, descendant, 
               (SELECT depth FROM organization.branch_closure WHERE ancestor = a.ancestor AND descendant = NEW.branch_id) + 
               (SELECT depth FROM organization.branch_closure WHERE ancestor = NEW.branch_id AND descendant = d.descendant) + 1
        FROM (SELECT ancestor FROM organization.branch_closure WHERE descendant = NEW.parent_branch_id) a
        CROSS JOIN (SELECT descendant FROM organization.branch_closure WHERE ancestor = NEW.branch_id) d;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger للحفاظ على اتساق branch_closure
DROP TRIGGER IF EXISTS maintain_branch_closure ON organization.branches;
CREATE TRIGGER maintain_branch_closure
    AFTER UPDATE OF parent_branch_id ON organization.branches
    FOR EACH ROW
    EXECUTE FUNCTION organization.maintain_branch_closure();

-- رسالة تأكيد
SELECT '✅ Branch closure maintenance trigger created successfully' AS status;