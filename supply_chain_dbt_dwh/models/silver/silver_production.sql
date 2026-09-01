SELECT 
    DISTINCT production_id, 
    CAST(date AS DATE) AS production_date, 
    TRIM(sku) AS sku, 
    output_quantity, 
    downtime_hours,
    COALESCE(downtime_reason, 'No Downtime') AS downtime_reason
    
FROM 
    {{ ref('bronze_production') }}
