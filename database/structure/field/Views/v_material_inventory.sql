-- =============================================
-- FILE: structure/field/Views/v_material_inventory.sql
-- PURPOSE: عرض مخزون مواد الاستكشاف
-- SCHEMA: field
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW field.v_material_inventory AS
SELECT 
    em.material_id,
    em.material_code,
    em.material_name_ar,
    em.material_name_en,
    em.material_type,
    CASE 
        WHEN em.material_type = 'drilling_equipment' THEN 'معدات حفر'
        WHEN em.material_type = 'chemicals' THEN 'مواد كيميائية'
        WHEN em.material_type = 'lab_tools' THEN 'أدوات معمل'
        WHEN em.material_type = 'fuel' THEN 'وقود'
        WHEN em.material_type = 'spare_parts' THEN 'قطع غيار'
        WHEN em.material_type = 'explosives' THEN 'متفجرات'
        WHEN em.material_type = 'safety_equipment' THEN 'معدات سلامة'
    END AS material_type_text,
    em.specifications,
    em.quantity,
    em.unit,
    em.reorder_level,
    CASE 
        WHEN em.quantity <= 0 THEN 'نفذ'
        WHEN em.quantity <= em.reorder_level THEN 'أقل من حد الطلب'
        ELSE 'متوفر'
    END AS stock_status,
    l.location_name_ar AS location,
    b.branch_name_ar AS branch,
    em.last_restock_date,
    em.expiry_date,
    CASE 
        WHEN em.expiry_date IS NOT NULL AND em.expiry_date < CURRENT_DATE THEN 'منتهي الصلاحية'
        WHEN em.expiry_date IS NOT NULL AND em.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'سينتهي قريباً'
        ELSE 'ساري'
    END AS expiry_status,
    em.supplier,
    em.notes,
    em.updated_at AS last_updated
FROM field.exploration_materials em
JOIN field.locations l ON em.location_id = l.location_id
JOIN organization.branches b ON em.branch_id = b.branch_id
ORDER BY 
    CASE 
        WHEN em.quantity <= em.reorder_level THEN 1
        WHEN em.expiry_date IS NOT NULL AND em.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 2
        ELSE 3
    END, em.material_name_ar;

COMMENT ON VIEW field.v_material_inventory IS 'مخزون مواد الاستكشاف';

-- رسالة تأكيد
SELECT '✅ View v_material_inventory created successfully' AS status;