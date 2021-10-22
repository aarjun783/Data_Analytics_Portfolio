-- Udemy Advanced SQL Course Traffic Analysis

/*
A breakdown by UTM source, campaign
and referring domain of website sessions
*/
SELECT 
	website_sessions.utm_source,website_sessions.utm_campaign,website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    round(COUNT(DISTINCT orders.order_id) *100/ COUNT(DISTINCT website_sessions.website_session_id),2) AS session_to_order_conv_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at < '2012-04-14'
group by 1,2,3;

-- the conversion rate (CVR) of gsearch nbrand from session to order?
SELECT 
    -- YEAR(website_sessions.created_at) as year,
    -- WEEK(website_sessions.created_at) as week,
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_sessions.created_at < '2012-05-15'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEAR(website_sessions.created_at), WEEK(website_sessions.created_at);

-- l gsearch nonbrand trended session volume, by week
SELECT 
    website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    ROUND(COUNT(DISTINCT orders.order_id) * 100 / COUNT(DISTINCT website_sessions.website_session_id),
            2) AS session_to_order_conv_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at < '2012-05-11'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;

-- conversion rates of gsearch nonbrand websites from session to order, by device type? 
SELECT 
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT CASE
            WHEN device_type = 'Desktop' THEN website_session_id else null
        END) AS dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'Mobile' THEN website_session_id else null
        END) AS mobile_sessions
FROM
    website_sessions
WHERE
    website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
        AND website_sessions.created_at BETWEEN '2012-04-15' AND '2012-06-09'
GROUP BY YEAR(website_sessions.created_at) , WEEK(website_sessions.created_at);
