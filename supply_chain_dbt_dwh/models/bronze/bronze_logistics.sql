SELECT *
FROM {{ source('supply_chain_source', 'logistics') }}