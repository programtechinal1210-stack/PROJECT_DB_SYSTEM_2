 
-- =============================================
-- FILE: seeds/02-organization/005-branches.sql
-- PURPOSE: إدراج الفروع الرئيسية
-- IDEMPOTENT: نعم (يمكن تشغيله عدة مرات)
-- =============================================

\c project_db_system;

DO $$
DECLARE
    v_main_type_id INT;
    v_hq_id INT;
BEGIN
    -- الحصول على معرف نوع الفرع الرئيسي
    SELECT type_id INTO v_main_type_id 
    FROM organization.branch_types 
    WHERE type_code = 'M1';
    
    -- إضافة فرع رئيسي تجريبي إذا لم يكن موجوداً
    IF NOT EXISTS (SELECT 1 FROM organization.branches WHERE branch_code = 'HQ') THEN
        SELECT organization.add_branch(
            'HQ', 
            'المركز الرئيسي', 
            v_main_type_id, 
            NULL
        ) INTO v_hq_id;
        
        RAISE NOTICE 'Main branch HQ created with ID: %', v_hq_id;
    END IF;
    
    -- إضافة فروع إقليمية
    IF NOT EXISTS (SELECT 1 FROM organization.branches WHERE branch_code = 'RIYADH') THEN
        PERFORM organization.add_branch(
            'RIYADH', 
            'فرع الرياض', 
            (SELECT type_id FROM organization.branch_types WHERE type_code = 'M'),
            (SELECT branch_id FROM organization.branches WHERE branch_code = 'HQ')
        );
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM organization.branches WHERE branch_code = 'JEDDAH') THEN
        PERFORM organization.add_branch(
            'JEDDAH', 
            'فرع جدة', 
            (SELECT type_id FROM organization.branch_types WHERE type_code = 'M'),
            (SELECT branch_id FROM organization.branches WHERE branch_code = 'HQ')
        );
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM organization.branches WHERE branch_code = 'DAMMAM') THEN
        PERFORM organization.add_branch(
            'DAMMAM', 
            'فرع الدمام', 
            (SELECT type_id FROM organization.branch_types WHERE type_code = 'M'),
            (SELECT branch_id FROM organization.branches WHERE branch_code = 'HQ')
        );
    END IF;
    
    -- إضافة فروع فرعية
    IF NOT EXISTS (SELECT 1 FROM organization.branches WHERE branch_code = 'RIYADH-SOUTH') THEN
        PERFORM organization.add_branch(
            'RIYADH-SOUTH', 
            'فرع جنوب الرياض', 
            (SELECT type_id FROM organization.branch_types WHERE type_code = 'S'),
            (SELECT branch_id FROM organization.branches WHERE branch_code = 'RIYADH')
        );
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM organization.branches WHERE branch_code = 'JEDDAH-NORTH') THEN
        PERFORM organization.add_branch(
            'JEDDAH-NORTH', 
            'فرع شمال جدة', 
            (SELECT type_id FROM organization.branch_types WHERE type_code = 'S'),
            (SELECT branch_id FROM organization.branches WHERE branch_code = 'JEDDAH')
        );
    END IF;
    
END $$;

-- عرض عدد الفروع
SELECT 
    '✅ Branches seeded' AS status,
    COUNT(*) AS total_branches
FROM organization.branches;