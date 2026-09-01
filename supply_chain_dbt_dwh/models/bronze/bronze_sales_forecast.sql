SELECT *
FROM {{ source('supply_chain_source', 'sales_forecast') }}