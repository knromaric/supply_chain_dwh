SELECT 
    lo.shipment_id, 
    lo.purchase_order_id, 
    p.supplier_id, 
    p.sku, 
    lo.transport_mode, 
    lo.shipment_cost, 
    lo.transit_delay_days
FROM {{ ref('silver_logistics') }} lo
LEFT JOIN {{ ref('silver_purchase_orders') }} p
    on lo.purchase_order_id = p.purchase_order_id
