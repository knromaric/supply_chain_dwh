SELECT  
    supplier_id, 
    supplier_name, 
    location, 
    rating 
FROM 
    {{ref("bronze_suppliers")}}