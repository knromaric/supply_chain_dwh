SELECT 
    p.purchase_order_id, 
    p.order_date,
    p.sku, 
    p.supplier_id, 
    s.supplier_name, 
    s.location, 
    s.rating, 
    p.quantity, 
    p.lead_time_days, 
    p.delivery_delay_days
FROM {{ ref('silver_purchase_orders') }} p
LEFT JOIN {{ ref('silver_suppliers') }} s
    ON p.supplier_id = s.supplier_id 