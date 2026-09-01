SELECT 
    sku, 
    warehouse_id, 
    supplier_id,
    current_stock,
    reorder_level, 
    inventory_status
FROM 
    {{ ref('silver_inventory') }}