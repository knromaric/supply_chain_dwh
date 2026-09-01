SELECT 
    purchase_order_id, 
    CAST(order_date AS DATE) AS order_date, 
    sku, 
    supplier_id, 
    quantity, 
    CAST(promised_delivery_date AS DATE) AS promised_delivery_date,
    CAST(actual_delivery_date AS DATE) AS actual_delivery_date,
    CAST(actual_delivery_date - order_date as INT) AS lead_time_days, 
    CAST(actual_delivery_date - promised_delivery_date AS INT) AS delivery_delay_days
FROM 
    {{ref("bronze_purchase_orders")}}