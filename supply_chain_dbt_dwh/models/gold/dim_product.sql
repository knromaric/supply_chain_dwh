SELECT DISTINCT
    sku
FROM 
    {{ ref('silver_inventory') }}