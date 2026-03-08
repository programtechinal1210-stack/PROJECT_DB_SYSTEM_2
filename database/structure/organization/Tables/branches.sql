 
-- =============================================
-- FILE: structure/organization/Tables/branches.sql
-- PURPOSE: إنشاء جدول الفروع
-- SCHEMA: organization
-- =============================================

\c project_db_system;

-- إنشاء جدول الفروع
CREATE TABLE IF NOT EXISTS organization.branches (
    branch_id SERIAL PRIMARY KEY,
    branch_code VARCHAR(50) UNIQUE NOT NULL,
    branch_name_ar VARCHAR(255) NOT NULL,
    branch_name_en VARCHAR(255),
    branch_type_id INT REFERENCES organization.branch_types(type_id),
    parent_branch_id INT REFERENCES organization.branches(branch_id) ON DELETE SET NULL,
    level INT NOT NULL DEFAULT 0,
    has_departments BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    position INT DEFAULT 0,
    operational_status_id INT REFERENCES organization.operational_statuses(status_id) DEFAULT 1,
    command_level INT NOT NULL DEFAULT 0,
    
    -- الموقع الجغرافي
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    address TEXT,
    
    -- معلومات إضافية
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- حقول التتبع
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES core.users(user_id),
    updated_by BIGINT REFERENCES core.users(user_id),
    
    -- القيود
    CONSTRAINT chk_parent_not_self CHECK (parent_branch_id IS NULL OR parent_branch_id != branch_id),
    CONSTRAINT chk_latitude CHECK (latitude IS NULL OR (latitude BETWEEN -90 AND 90)),
    CONSTRAINT chk_longitude CHECK (longitude IS NULL OR (longitude BETWEEN -180 AND 180))
);

-- إضافة تعليقات
COMMENT ON TABLE organization.branches IS 'جدول الفروع والهيكل التنظيمي';
COMMENT ON COLUMN organization.branches.branch_id IS 'المعرف الفريد للفرع';
COMMENT ON COLUMN organization.branches.branch_code IS 'كود الفرع الفريد';
COMMENT ON COLUMN organization.branches.branch_name_ar IS 'اسم الفرع بالعربية';
COMMENT ON COLUMN organization.branches.branch_name_en IS 'اسم الفرع بالإنجليزية';
COMMENT ON COLUMN organization.branches.branch_type_id IS 'نوع الفرع';
COMMENT ON COLUMN organization.branches.parent_branch_id IS 'الفرع الأب';
COMMENT ON COLUMN organization.branches.level IS 'مستوى الفرع في الشجرة الهرمية';
COMMENT ON COLUMN organization.branches.has_departments IS 'هل يحتوي الفرع على إدارات';
COMMENT ON COLUMN organization.branches.requires_approval IS 'هل يتطلب اعتماد';
COMMENT ON COLUMN organization.branches.command_level IS 'مستوى القيادة (للصلاحيات)';
COMMENT ON COLUMN organization.branches.operational_status_id IS 'حالة التشغيل';
COMMENT ON COLUMN organization.branches.latitude IS 'خط العرض';
COMMENT ON COLUMN organization.branches.longitude IS 'خط الطول';
COMMENT ON COLUMN organization.branches.address IS 'العنوان التفصيلي';

-- رسالة تأكيد
SELECT '✅ Table branches created successfully' AS status;