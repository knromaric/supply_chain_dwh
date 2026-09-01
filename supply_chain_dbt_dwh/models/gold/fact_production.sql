SELECT 
    p.production_id, 
    p.production_date, 
    p.sku, 
    p.output_quantity, 
    p.downtime_hours,
    p.downtime_reason,
    c.year, 
    c.month, 
    c.week 
FROM 
    {{ ref('silver_production') }} p
LEFT JOIN {{ ref('silver_calendar') }} c
    ON p.production_date = c.date