-- =============================================
-- FILE: structure/assets/Views/v_resource_inventory.sql
-- PURPOSE: عرض مخزون الموارد
-- SCHEMA: assets
-- =============================================

\c project_db_system;

-- إنشاء أو استبدال العرض
CREATE OR REPLACE VIEW assets.v_resource_inventory AS
SELECT 
    r.resource_id,
    r.resource_code,
    r.resource_name_ar,
    rt.type_name_ar AS resource_type,
    r.unit,
    r.current_stock,
    r.minimum_stock,
    r.maximum_stock,
    r.reorder_level,
    CASE 
        WHEN r.current_stock <= 0 THEN 'نفذ'
        WHEN r.current_stock <= r.reorder_level THEN 'أقل من حد الطلب'
        WHEN r.current_stock <= r.minimum_stock THEN 'أقل من الحد الأدنى'
        WHEN r.current_stock >= r.maximum_stock THEN 'أكثر من الحد الأقصى'
        ELSE 'طبيعي'
    END AS stock_status,
    CASE 
        WHEN r.current_stock <= r.reorder_level THEN r.reorder_level - r.current_stock
        ELSE 0
    END AS suggested_order_quantity,
    r.location,
    r.updated_at AS last_updated
FROM assets.resources r
LEFT JOIN assets.resource_types rt ON r.type_id = rt.type_id
WHERE r.current_stock IS NOT NULL
ORDER BY 
    CASE 
        WHEN r.current_stock <= r.reorder_level THEN 1
        WHEN r.current_stock <= r.minimum_stock THEN 2
        WHEN r.current_stock >= r.maximum_stock THEN 3
        ELSE 4
    END, r.resource_name_ar;

COMMENT ON VIEW assets.v_resource_inventory IS 'حالة مخزون الموارد';

-- رسالة تأكيد
SELECT '✅ View v_resource_inventory created successfully' AS status;