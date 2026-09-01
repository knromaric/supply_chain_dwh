SELECT DISTINCT
    TRIM(sku) AS sku, 
    warehouse_id, 
    supplier_id,
    current_stock, 
    reorder_level,
    CASE
        WHEN current_stock <= reorder_level THEN 'Reorder'
        ELSE 'Sufficient'
    END AS inventory_status
FROM 
    {{ref('bronze_inventory')}}