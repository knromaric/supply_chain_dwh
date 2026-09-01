SELECT 
    CAST(date as DATE) as forecast_date, 
    sku, 
    historical_demand, 
    forecasted_demand,
    forecasted_demand - historical_demand AS forecast_bias, 
    ROUND(
        CAST((1-ABS(forecasted_demand-historical_demand)) AS DOUBLE) /
        NULLIF(historical_demand, 0) * 100, 
        2
    ) as forecast_accuracy
FROM 
    {{ref("bronze_sales_forecast")}}