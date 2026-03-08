 
-- =============================================
-- FILE: structure/organization/Tables/branch_closure.sql
-- PURPOSE: إنشاء جدول Closure للهيكل الهرمي للفروع
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول Closure للتعامل مع الشجرة الهرمية
CREATE TABLE IF NOT EXISTS organization.branch_closure (
    ancestor INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
    descendant INT NOT NULL REFERENCES organization.branches(branch_id) ON DELETE CASCADE,
    depth INT NOT NULL,
    PRIMARY KEY (ancestor, descendant),
    CONSTRAINT chk_depth_non_negative CHECK (depth >= 0)
);

-- إضافة تعليقات
COMMENT ON TABLE organization.branch_closure IS 'جدول Closure للتعامل مع الشجرة الهرمية للفروع';
COMMENT ON COLUMN organization.branch_closure.ancestor IS 'الفرع الأب';
COMMENT ON COLUMN organization.branch_closure.descendant IS 'الفرع الابن';
COMMENT ON COLUMN organization.branch_closure.depth IS 'عمق العلاقة (0 يعني نفس الفرع)';

-- رسالة تأكيد
SELECT '✅ Table branch_closure created successfully' AS status;