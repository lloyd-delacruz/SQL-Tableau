CREATE SCHEMA britishairways_reviews;

CREATE TABLE britishairways_reviews.ba_reviews (
    header TEXT,
    author TEXT,
    date DATE,
    place TEXT,
    content TEXT,
    aircraft TEXT,
    traveller_type TEXT,
    seat_type TEXT,
    route TEXT,
    date_flown DATE,
    recommended TEXT,
    trip_verified TEXT,
    rating INT,
    seat_comfort INT,
    cabin_staff_service INT,
    food_beverages INT,
    ground_service INT,
    value_for_money INT,
    entertainment INT
);
SET datestyle = 'DMY';

COPY britishairways_reviews.ba_reviews
FROM '/Users/lloyd.vince1985gmail.com/Desktop/Data Analytics/Tableau/BA_Dataset/ba_reviews.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE britishairways_reviews.countries (
    country TEXT NOT NULL,
    code CHAR(3),
    continent TEXT NOT NULL,
    region TEXT NOT NULL
);

COPY britishairways_reviews.countries
FROM '/Users/lloyd.vince1985gmail.com/Desktop/Data Analytics/Tableau/BA_Dataset/Countries.csv'
DELIMITER ','
CSV HEADER;

--BA reviews data
--Data exploration
SELECT *
FROM britishairways_reviews.ba_reviews
LIMIT 10;

SELECT COUNT(*) 
FROM britishairways_reviews.ba_reviews;

SELECT *
FROM britishairways_reviews.countries; 

SELECT 
    COUNT(*) AS total_rows,
    COUNT(header) AS non_null_header,
    COUNT(author) AS non_null_author,
    COUNT(date) AS non_null_date,
    COUNT(place) AS non_null_place,
    COUNT(content) AS non_null_content,
    COUNT(aircraft) AS non_null_aircraft,
    COUNT(traveller_type) AS non_null_traveller_type,
    COUNT(seat_type) AS non_null_seat_type,
    COUNT(route) AS non_null_route,
    COUNT(date_flown) AS non_null_date_flown,
    COUNT(recommended) AS non_null_recommended,
    COUNT(trip_verified) AS non_null_trip_verified,
    COUNT(rating) AS non_null_rating,
    COUNT(seat_comfort) AS non_null_seat_comfort,
    COUNT(cabin_staff_service) AS non_null_cabin_staff_service,
    COUNT(food_beverages) AS non_null_food_beverages,
    COUNT(ground_service) AS non_null_ground_service,
    COUNT(value_for_money) AS non_null_value_for_money,
    COUNT(entertainment) AS non_null_entertainment
FROM britishairways_reviews.ba_reviews;

SELECT 
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating,
    MIN(seat_comfort) AS min_seat_comfort,
    MAX(seat_comfort) AS max_seat_comfort,
    AVG(seat_comfort) AS avg_seat_comfort
FROM britishairways_reviews.ba_reviews;

--BA reviews Data cleaning
ALTER TABLE britishairways_reviews.ba_reviews
ADD COLUMN origin TEXT,
ADD COLUMN destination TEXT;

UPDATE britishairways_reviews.ba_reviews
SET origin = SPLIT_PART(route, ' to ', 1);

UPDATE britishairways_reviews.ba_reviews
SET destination = SPLIT_PART(route, ' to ', 2);

UPDATE britishairways_reviews.ba_reviews
SET destination = SPLIT_PART(route, ' to ', 2);

--countries data exploration
SELECT *
FROM britishairways_reviews.countries; 

SELECT COUNT(*) AS total_countries 
FROM britishairways_reviews.countries;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(country) AS non_null_country,
    COUNT(code) AS non_null_code,
    COUNT(continent) AS non_null_continent,
    COUNT(region) AS non_null_region
FROM britishairways_reviews.countries;

SELECT continent, COUNT(*) AS country_count
FROM britishairways_reviews.countries
GROUP BY continent
ORDER BY country_count DESC;

--Joining the table together
SELECT 
    br.header,
    br.author,
    br.place,
    br.route,
    br.date_flown,
    br.rating,
    br.value_for_money,
    c.continent,
    c.region
FROM 
    britishairways_reviews.ba_reviews br
LEFT JOIN 
    britishairways_reviews.countries c
ON 
    br.place = c.country;

--Analysis 
--Customer sentiment metric

SELECT CAST(AVG(rating) AS INT) AS avg_rating 
FROM britishairways_reviews.ba_reviews;

---Percentage of recommended reviews
SELECT 
    recommended, 
    ROUND(COUNT(*) * 100.0 / 
		(SELECT COUNT(*) 
		FROM britishairways_reviews.ba_reviews), 2) AS percentage
FROM britishairways_reviews.ba_reviews
GROUP BY recommended
ORDER BY percentage;

--Volume metrics
---Reviews by Traveller type
SELECT traveller_type, COUNT(*) AS review_count
FROM britishairways_reviews.ba_reviews
WHERE traveller_type IS NOT NULL 
GROUP BY traveller_type
ORDER BY review_count DESC;

---Reviews by Date
SELECT DATE_TRUNC('year', date) AS review_year, COUNT(*) AS review_count
FROM britishairways_reviews.ba_reviews
GROUP BY review_year
ORDER BY review_year DESC;

---Reviews by Date - ranked
WITH yearly_reviews AS (
    SELECT 
        DATE_TRUNC('year', date) AS review_year, 
        COUNT(*) AS review_count
    FROM britishairways_reviews.ba_reviews
    GROUP BY review_year
)
SELECT 
    review_year, 
    review_count,
    RANK() OVER (ORDER BY review_count DESC) AS rank
FROM yearly_reviews
ORDER BY rank;

--Service quality metric 
---Rating
SELECT 
    ROUND(AVG(rating), 2) AS avg_rating
FROM britishairways_reviews.ba_reviews;

SELECT 
    ROUND(AVG(seat_comfort), 2) AS avg_seat_comfort,
    ROUND(AVG(cabin_staff_service), 2) AS avg_cabin_staff_service,
    ROUND(AVG(value_for_money), 2) AS avg_value_for_money,
    ROUND(AVG(food_beverages), 2) AS avg_food_beverages,
    ROUND(AVG(ground_service), 2) AS avg_ground_service,
    ROUND(AVG(entertainment), 2) AS avg_entertainment
FROM britishairways_reviews.ba_reviews;

--Ranking the services
---Ranking the services helps identify which aspects of the customer experience perform best and which need improvement, enabling targeted strategies to enhance overall satisfaction and prioritize resource allocation effectively.
WITH service_metrics AS (
    SELECT 
        ROUND(AVG(seat_comfort), 2) AS avg_seat_comfort,
        ROUND(AVG(cabin_staff_service), 2) AS avg_cabin_staff_service,
        ROUND(AVG(value_for_money), 2) AS avg_value_for_money,
        ROUND(AVG(food_beverages), 2) AS avg_food_beverages,
        ROUND(AVG(ground_service), 2) AS avg_ground_service,
        ROUND(AVG(entertainment), 2) AS avg_entertainment
    FROM britishairways_reviews.ba_reviews
)
SELECT 
    metric, 
    average,
    RANK() OVER (ORDER BY average DESC) AS rank
FROM (
    SELECT 'Seat Comfort' AS metric, avg_seat_comfort AS average FROM service_metrics
    UNION ALL
    SELECT 'Cabin Staff Service', avg_cabin_staff_service FROM service_metrics
    UNION ALL
    SELECT 'Value for Money', avg_value_for_money FROM service_metrics
    UNION ALL
    SELECT 'Food & Beverages', avg_food_beverages FROM service_metrics
    UNION ALL
    SELECT 'Ground Service', avg_ground_service FROM service_metrics
    UNION ALL
    SELECT 'Entertainment', avg_entertainment FROM service_metrics
) AS ranked_metrics
ORDER BY rank;


--Geographical Metrics
--By country
SELECT 
    br.place, 
    ROUND(AVG(br.rating), 2) AS avg_rating 
FROM britishairways_reviews.ba_reviews br
GROUP BY br.place
ORDER BY avg_rating DESC;

--By continent
SELECT 
    c.continent, 
    COUNT(*) AS review_count
FROM britishairways_reviews.ba_reviews br
LEFT JOIN britishairways_reviews.countries c
ON br.place = c.country
GROUP BY c.continent
ORDER BY review_count DESC;

--Cities/airports with most flight
SELECT 
    br.origin AS country,
    COUNT(*) AS flight_count
FROM britishairways_reviews.ba_reviews br
GROUP BY br.origin
ORDER BY flight_count DESC;

--continents with most flights
SELECT 
    c.continent,
    COUNT(*) AS flight_count
FROM britishairways_reviews.ba_reviews br
JOIN britishairways_reviews.countries c
ON br.origin = c.country
GROUP BY c.continent
ORDER BY flight_count DESC;


--Trip verification metrics
SELECT 
    trip_verified, 
    ROUND(COUNT(*) * 100.0 / 
		(SELECT COUNT(*) 
			FROM britishairways_reviews.ba_reviews), 2) AS percentage
FROM britishairways_reviews.ba_reviews
GROUP BY trip_verified

--Aircraft service metric
WITH aircraft_metrics AS (
    SELECT 
        aircraft,
        ROUND(AVG(rating), 2) AS avg_rating,
        ROUND(AVG(seat_comfort), 2) AS avg_seat_comfort,
        ROUND(AVG(cabin_staff_service), 2) AS avg_cabin_staff_service,
        ROUND(AVG(food_beverages), 2) AS avg_food_beverages,
        ROUND(AVG(ground_service), 2) AS avg_ground_service,
        ROUND(AVG(entertainment), 2) AS avg_entertainment
    FROM britishairways_reviews.ba_reviews
    GROUP BY aircraft
)
SELECT 
    aircraft,
    CASE 
        WHEN aircraft ILIKE 'A%' THEN 'Airbus'
        WHEN aircraft ILIKE 'B%' THEN 'Boeing'
        ELSE 'Other'
    END AS manufacturer,
    avg_rating,
    avg_seat_comfort,
    avg_cabin_staff_service,
    avg_food_beverages,
    avg_ground_service,
    avg_entertainment
FROM aircraft_metrics
ORDER BY avg_rating DESC;


WITH aircraft_metrics AS (
    SELECT 
        aircraft,
        ROUND(AVG(rating), 2) AS avg_rating,
        ROUND(AVG(seat_comfort), 2) AS avg_seat_comfort,
        ROUND(AVG(cabin_staff_service), 2) AS avg_cabin_staff_service,
        ROUND(AVG(food_beverages), 2) AS avg_food_beverages,
        ROUND(AVG(ground_service), 2) AS avg_ground_service,
        ROUND(AVG(entertainment), 2) AS avg_entertainment
    FROM britishairways_reviews.ba_reviews
    GROUP BY aircraft
),
classified_aircraft AS (
    SELECT 
        aircraft,
        CASE 
            WHEN aircraft ILIKE 'A%' THEN 'Airbus'
            WHEN aircraft ILIKE 'B%' THEN 'Boeing'
            ELSE 'Other'
        END AS manufacturer,
        avg_rating,
        avg_seat_comfort,
        avg_cabin_staff_service,
        avg_food_beverages,
        avg_ground_service,
        avg_entertainment
    FROM aircraft_metrics
)
SELECT 
    manufacturer,
    COUNT(*) AS total_aircraft,
    ROUND(AVG(avg_rating), 2) AS overall_avg_rating,
    ROUND(AVG(avg_seat_comfort), 2) AS overall_avg_seat_comfort,
    ROUND(AVG(avg_cabin_staff_service), 2) AS overall_avg_cabin_staff_service,
    ROUND(AVG(avg_food_beverages), 2) AS overall_avg_food_beverages,
    ROUND(AVG(avg_ground_service), 2) AS overall_avg_ground_service,
    ROUND(AVG(avg_entertainment), 2) AS overall_avg_entertainment
FROM classified_aircraft
GROUP BY manufacturer
ORDER BY manufacturer;

--No of airbus and boeing aircraft with each subtype
WITH aircraft_classification AS (
    SELECT 
        br.aircraft,
        CASE 
            WHEN br.aircraft ILIKE 'A%' THEN 'Airbus'
            WHEN br.aircraft ILIKE 'B%' THEN 'Boeing'
            ELSE 'Other'
        END AS manufacturer
    FROM britishairways_reviews.ba_reviews br
    GROUP BY br.aircraft
)
SELECT 
    ac.manufacturer,
    ac.aircraft,
    COUNT(br.aircraft) AS flight_count
FROM aircraft_classification ac
JOIN britishairways_reviews.ba_reviews br ON ac.aircraft = br.aircraft
GROUP BY ac.manufacturer, ac.aircraft
ORDER BY ac.manufacturer, flight_count DESC;

--Only showing the top 10 for each make/aircraft subtype
WITH aircraft_classification AS (
    SELECT 
        br.aircraft,
        CASE 
            WHEN br.aircraft ILIKE 'A%' THEN 'Airbus'
            WHEN br.aircraft ILIKE 'B%' THEN 'Boeing'
            ELSE 'Other'
        END AS manufacturer
    FROM britishairways_reviews.ba_reviews br
    GROUP BY br.aircraft
),
ranked_aircraft AS (
    SELECT 
        ac.manufacturer,
        ac.aircraft,
        COUNT(br.aircraft) AS flight_count,
        ROW_NUMBER() OVER (PARTITION BY ac.manufacturer ORDER BY COUNT(br.aircraft) DESC) AS rank
    FROM aircraft_classification ac
    JOIN britishairways_reviews.ba_reviews br ON ac.aircraft = br.aircraft
    GROUP BY ac.manufacturer, ac.aircraft
)
SELECT 
    manufacturer,
    aircraft,
    flight_count,
    rank
FROM ranked_aircraft
WHERE rank <= 10
ORDER BY manufacturer, rank;

--Raitng per aircraft
WITH aircraft_classification AS (
    SELECT 
        br.aircraft,
        CASE 
            WHEN br.aircraft ILIKE 'A%' THEN 'Airbus'
            WHEN br.aircraft ILIKE 'B%' THEN 'Boeing'
            ELSE 'Other'
        END AS manufacturer
    FROM britishairways_reviews.ba_reviews br
    GROUP BY br.aircraft
),
ranked_aircraft AS (
    SELECT 
        ac.manufacturer,
        ac.aircraft,
        COUNT(br.aircraft) AS flight_count,
        ROUND(AVG(br.rating), 2) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY ac.manufacturer ORDER BY AVG(br.rating) DESC) AS rank
    FROM aircraft_classification ac
    JOIN britishairways_reviews.ba_reviews br ON ac.aircraft = br.aircraft
    GROUP BY ac.manufacturer, ac.aircraft
)
SELECT 
    manufacturer,
    aircraft,
    flight_count,
    avg_rating,
    rank
FROM ranked_aircraft
WHERE rank <= 10
ORDER BY manufacturer, rank;

--No of aircraft vs rating ranked according to no. of aircraft 
WITH aircraft_classification AS (
    SELECT 
        br.aircraft,
        CASE 
            WHEN br.aircraft ILIKE 'A%' THEN 'Airbus'
            WHEN br.aircraft ILIKE 'B%' THEN 'Boeing'
            ELSE 'Other'
        END AS manufacturer
    FROM britishairways_reviews.ba_reviews br
    GROUP BY br.aircraft
),
ranked_aircraft AS (
    SELECT 
        ac.manufacturer,
        ac.aircraft,
        COUNT(br.aircraft) AS flight_count,
        ROUND(AVG(br.rating), 2) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY ac.manufacturer ORDER BY COUNT(br.aircraft) DESC) AS rank
    FROM aircraft_classification ac
    JOIN britishairways_reviews.ba_reviews br ON ac.aircraft = br.aircraft
    GROUP BY ac.manufacturer, ac.aircraft
)
SELECT 
    manufacturer,
    aircraft,
    flight_count,
    avg_rating,
    rank
FROM ranked_aircraft
WHERE rank <= 10
ORDER BY manufacturer, rank;

---Aircraft and entertainment review
WITH aircraft_classification AS (
    SELECT 
        br.aircraft,
        CASE 
            WHEN br.aircraft ILIKE 'A%' THEN 'Airbus'
            WHEN br.aircraft ILIKE 'B%' THEN 'Boeing'
            ELSE 'Other'
        END AS manufacturer
    FROM britishairways_reviews.ba_reviews br
    GROUP BY br.aircraft
),
ranked_aircraft AS (
    SELECT 
        ac.manufacturer,
        ac.aircraft,
        COUNT(br.aircraft) AS flight_count,
        ROUND(AVG(br.entertainment), 2) AS avg_entertainment,
        DENSE_RANK() OVER (PARTITION BY ac.manufacturer ORDER BY ROUND(AVG(br.entertainment), 2) DESC) AS rank
    FROM aircraft_classification ac
    JOIN britishairways_reviews.ba_reviews br ON ac.aircraft = br.aircraft
    GROUP BY ac.manufacturer, ac.aircraft
)
SELECT 
    manufacturer,
    aircraft,
    flight_count,
    avg_entertainment,
    rank
FROM ranked_aircraft
WHERE avg_entertainment >= 1
ORDER BY manufacturer, rank;


--Review by traveller type
SELECT 
    traveller_type,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS review_count
FROM britishairways_reviews.ba_reviews
WHERE traveller_type IS NOT NULL
GROUP BY traveller_type
ORDER BY avg_rating DESC;

--Review of seat comfort
SELECT 
    seat_type,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(seat_comfort), 2) AS avg_seat_comfort,
    COUNT(*) AS flight_count
FROM britishairways_reviews.ba_reviews
GROUP BY seat_type
ORDER BY avg_rating DESC;







