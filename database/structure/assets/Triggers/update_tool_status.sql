-- =============================================
-- FILE: structure/assets/Triggers/update_tool_status.sql
-- PURPOSE: تحديث حالة الأداة بناءً على التكليفات
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- دالة تحديث حالة الأداة
CREATE OR REPLACE FUNCTION assets.update_tool_status()
RETURNS TRIGGER AS $$
BEGIN
    -- عند إضافة تكليف جديد
    IF TG_OP = 'INSERT' THEN
        UPDATE assets.tools
        SET status = 'in_use'
        WHERE tool_id = NEW.tool_id;
        RETURN NEW;
        
    -- عند تحديث تكليف (مثل الإرجاع)
    ELSIF TG_OP = 'UPDATE' THEN
        -- إذا تم الإرجاع
        IF NEW.actual_return_date IS NOT NULL AND OLD.actual_return_date IS NULL THEN
            -- التحقق من عدم وجود تكليفات نشطة أخرى
            IF NOT EXISTS (
                SELECT 1 FROM assets.tool_assignments 
                WHERE tool_id = NEW.tool_id 
                  AND actual_return_date IS NULL
                  AND assignment_id != NEW.assignment_id
            ) THEN
                UPDATE assets.tools
                SET status = CASE 
                    WHEN NEW.condition_on_return = 'damaged' THEN 'damaged'
                    ELSE 'available'
                END
                WHERE tool_id = NEW.tool_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث حالة الأداة
DROP TRIGGER IF EXISTS update_tool_status ON assets.tool_assignments;
CREATE TRIGGER update_tool_status
    AFTER INSERT OR UPDATE ON assets.tool_assignments
    FOR EACH ROW
    EXECUTE FUNCTION assets.update_tool_status();

-- رسالة تأكيد
SELECT '✅ Tool status update trigger created successfully' AS status;