SELECT
    CAST(date AS DATE) AS date, 
    year,	
    quarter,	
    month,	
    week,	
    day,
    day_of_week
FROM 
    {{ref("bronze_calendar")}}