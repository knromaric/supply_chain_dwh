SELECT *
FROM {{ source('supply_chain_source', 'inventory') }}