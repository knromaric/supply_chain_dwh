SELECT DISTINCT 
    warehouse_id
FROM 
    {{ ref('silver_inventory') }}