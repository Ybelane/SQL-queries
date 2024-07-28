/*
*/
SELECT
    SUM(CASE WHEN EXTRACT(DOW FROM departure_time) IN (1, 2, 3, 4, 5) THEN 1 ELSE 0 END) AS working_cnt,
    SUM(CASE WHEN EXTRACT(DOW FROM departure_time) IN (0, 6) THEN 1 ELSE 0 END) AS weekend_cnt
FROM
    flights;
/*
*/
WITH user_discounts AS (
    SELECT 
        s.user_id,
        AVG(s.hotel_discount_amount) AS avg_discount,
        MAX(s.hotel_discount_amount) AS max_discount
    FROM 
        sessions s
    WHERE 
        s.hotel_discount = TRUE AND
        s.cancellation = FALSE
    GROUP BY 
        s.user_id
    HAVING 
        COUNT(DISTINCT s.trip_id) >= 2
),
max_avg_discount AS (
    SELECT 
        MAX(avg_discount) AS max_avg
    FROM 
        user_discounts
)
SELECT 
    user_id
FROM 
    user_discounts
WHERE 
    max_discount > (SELECT max_avg FROM max_avg_discount);
/*
*/
WITH airport_services AS (
    SELECT origin_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY origin_airport
    UNION ALL
    SELECT destination_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY destination_airport
)
SELECT airport
FROM airport_services
GROUP BY airport
ORDER BY SUM(services) DESC
LIMIT 1;
/*

*/
WITH airport_services AS (
    SELECT origin_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY origin_airport
    UNION ALL
    SELECT destination_airport AS airport, COUNT(*) AS services
    FROM flights
    GROUP BY destination_airport
),
ranked_airports AS (
    SELECT 
        airport, 
        ROW_NUMBER() OVER (ORDER BY SUM(services) ASC) AS airport_rank,
        SUM(services) AS total_services
    FROM airport_services
    GROUP BY airport
)
SELECT 
    airport, 
    ROUND((airport_rank - 1) * 100.0 / (COUNT(*) OVER () - 1), 1) AS percent_rank
FROM ranked_airports
ORDER BY airport_rank;

