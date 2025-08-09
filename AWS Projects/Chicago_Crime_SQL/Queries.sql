Time Series Analysis
#Question 1 : Number of crimes per year between 2015 and 2025
SELECT year,count(*) as number_of_crimes from "raw_data"
group by year
order by year asc;

#Question 2 : Number of crimes segmented per month between 2015 and 2025
SELECT
    month(date_parse(date, '%m/%d/%Y %h:%i:%s %p')) AS crime_month,
    year(date_parse(date, '%m/%d/%Y %h:%i:%s %p')) AS crime_year,
    count(*) as number_of_crimes
    from
    "raw_data"
    group by 1,2
    order by 
    crime_year asc,crime_month asc

#Question 3 : Differences between weekdays and weekend nights on types of crimes committed
WITH crime_periods AS (
    -- Step 1: Categorize each crime record into a time period
    SELECT
        "primary type" as crime_committed,
        CASE
            -- Saturday and Sunday nights
            WHEN (day_of_week(date_parse(date, '%m/%d/%Y %h:%i:%s %p')) = 6 and hour(date_parse(date, '%m/%d/%Y %h:%i:%s %p'))>=18)
              OR (day_of_week(date_parse(date, '%m/%d/%Y %h:%i:%s %p')) = 7 and hour(date_parse(date, '%m/%d/%Y %h:%i:%s %p'))<=5)
            THEN 'Weekend nights'
            -- Monday through Friday (all day)
            WHEN day_of_week(date_parse(date, '%m/%d/%Y %h:%i:%s %p')) BETWEEN 1 AND 5
            THEN 'Weekday'
            ELSE 'Other'
        END AS time_period
    FROM
        "raw_data"
)
-- Step 2: Count the crimes and group them by the new categories
SELECT
    time_period,
    crime_committed,
    COUNT(*) AS crime_count
FROM
    crime_periods
GROUP BY
    time_period,
    crime_committed
ORDER BY
    time_period,
    crime_count DESC;

