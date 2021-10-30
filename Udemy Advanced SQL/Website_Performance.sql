-- Udemy Advanced SQL Course Website Performance

-- Most Viewed Website Pages 
SELECT 
    pageview_url, COUNT(distinct website_pageview_id) AS page_views
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY 2 DESC;

-- List of Top Entry Pages
Create temporary table views
SELECT 
    MIN(website_pageview_id) as min_id,
    website_session_id
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12'
group by 2;


SELECT 
    website_pageviews.pageview_url as landing_page, COUNT(DISTINCT website_pageview_id) as sessions_hitting_page
FROM
    views
        LEFT JOIN
    website_pageviews ON website_pageview_id = views.min_id
    where website_pageviews.pageview_url='\home'
GROUP BY 1;

-- Bounce Rate of Homepages
CREATE TEMPORARY TABLE bounce_sessions
SELECT
	website_session_id AS bounced_website_session_id,
	COUNT(website_pageview_id) AS page_views
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id
HAVING page_views = 1;
 
SELECT
	COUNT(DISTINCT website_pageviews.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounce_sessions.bounced_website_session_id) AS bounced,
    COUNT(DISTINCT bounce_sessions.bounced_website_session_id)/COUNT(DISTINCT website_pageviews.website_session_id) as bounce_rate
FROM website_pageviews
LEFT JOIN bounce_sessions
	ON website_pageviews.website_session_id = bounce_sessions.bounced_website_session_id
WHERE website_pageviews.created_at < '2012-06-14';

-- Bounce rates of two groups
-- finding the first instance of \lander-1 for setting the analysis timeframe
SELECT 
    MIN(created_at), website_pageview_id
FROM
    website_pageviews
WHERE
    created_at < '2012-07-28'
        AND pageview_url = '/lander-1';
        
-- Gather the number of bounced sessions
create temporary table bounce
SELECT 
    website_sessions.website_session_id as bounced_id, COUNT(distinct website_pageviews.website_pageview_id) as bounced_sessions
FROM
    website_pageviews inner join website_sessions on website_pageviews.website_session_id=website_sessions.website_session_id
WHERE
    website_pageviews.created_at between '2012-06-19' and '2012-07-28' and website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand' and website_pageviews.website_pageview_id>23504
group by 1
HAVING bounced_sessions = 1;

select * from bounce;

-- Gather the bounce rates of the two webpages between june 19th and july 28th
SELECT 
    website_pageviews.pageview_url,
    COUNT(DISTINCT website_pageviews.website_session_id) as total_sessions,
    COUNT(DISTINCT bounce.bounced_id) as bounced_sessions,
    COUNT(DISTINCT bounce.bounced_id)/COUNT(DISTINCT website_pageviews.website_session_id) as bounce_rate
FROM
    website_pageviews left join bounce on website_pageviews.website_session_id=bounce.bounced_id
    inner join website_sessions on website_sessions.website_session_id=website_pageviews.website_session_id
WHERE
    website_pageviews.created_at between '2012-06-19' and '2012-07-28' and website_pageviews.pageview_url in ('/home','/lander-1') and website_pageviews.website_pageview_id>23504 and website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand'
GROUP BY 1;

with bounced as (SELECT 
    website_sessions.website_session_id as bounced_id, COUNT(distinct website_pageviews.website_pageview_id) as bounced_sessions
FROM
    website_pageviews inner join website_sessions on website_pageviews.website_session_id=website_sessions.website_session_id
WHERE
    website_pageviews.created_at between '2012-06-01' and '2012-08-31' and website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand'
group by 1
HAVING bounced_sessions = 1)

SELECT 
    MIN(website_sessions.created_at) AS week_start_date,
    COUNT(DISTINCT bounced.bounced_id) / COUNT(DISTINCT website_pageviews.website_session_id) as bounced_sessions,
    count(distinct case when website_pageviews.pageview_url = '/home' then website_pageviews.website_session_id else null end) as home_sessions,
    count(distinct case when website_pageviews.pageview_url = '/lander-1' then website_pageviews.website_session_id else null end) as lander_sessions
FROM
    website_pageviews
        LEFT JOIN
    bounced ON bounced.bounced_id = website_pageviews.website_session_id
        INNER JOIN
    website_sessions ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE 
    website_pageviews.created_at between '2012-06-01' and '2012-08-31' and website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand'
    group by year(website_sessions.created_at),week(website_sessions.created_at);

	-- Conversion Funnel from lander-1 to order confirmation page
SELECT 
    COUNT(flags.session_id) AS sessions,
    COUNT(CASE
        WHEN products_pages = 1 THEN flags.session_id
        ELSE NULL
    END) AS to_products,
    COUNT(CASE
        WHEN mr_fuzzy_pages = 1 THEN flags.session_id
        ELSE NULL
    END) AS to_mr_fuzzy,
    COUNT(CASE
        WHEN cart_pages = 1 THEN flags.session_id
        ELSE NULL
    END) AS to_cart,
    COUNT(CASE
        WHEN shipping_pages = 1 THEN flags.session_id
        ELSE NULL
    END) AS to_shipping,
    COUNT(CASE
        WHEN billing_pages = 1 THEN flags.session_id
        ELSE NULL
    END) AS to_billing,
    COUNT(CASE
        WHEN thank_pages = 1 THEN flags.session_id
        ELSE NULL
    END) AS to_thank_you
FROM
    (SELECT 
        website_sessions.website_session_id AS session_id,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/lander-1' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS lander_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/products' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS products_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS mr_fuzzy_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/cart' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS cart_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/shipping' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS shipping_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/billing' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS billing_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS thank_pages
    FROM
        website_pageviews
    INNER JOIN website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
    WHERE
        website_pageviews.created_at BETWEEN '2012-08-05' AND '2012-09-05'
            AND website_sessions.utm_source = 'gsearch'
            AND website_sessions.utm_campaign = 'nonbrand'
            AND website_pageviews.pageview_url IN ('/lander-1' , '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
    GROUP BY 1) flags;

--Comparison between conversion funnels of that of original billing page and thaht of updated billing page (billing-2)

SELECT 
    MIN(website_pageviews.created_at),
    website_pageviews.website_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/billing-2';

SELECT 
    website_pageviews.pageview_url as billing_version_seen,
    COUNT(DISTINCT website_pageviews.website_session_id) as sessions,
    count(distinct case when billings.order_pages=1 THEN website_pageviews.website_session_id
                ELSE NULL end) as orders,
	count(distinct case when billings.order_pages=1 THEN website_pageviews.website_session_id
                ELSE NULL end)/COUNT(DISTINCT website_pageviews.website_session_id) as billing_to_order_rt
FROM
    website_pageviews
        LEFT JOIN
    (SELECT 
        website_sessions.website_session_id AS session_id,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/billing' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS billing_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/billing-2' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS second_billing_pages,
            COUNT(DISTINCT CASE
                WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN website_pageviews.pageview_url
                ELSE NULL
            END) AS order_pages
    FROM
        website_pageviews
    INNER JOIN website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
    WHERE
        website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
            AND website_pageviews.pageview_url IN ('/billing' , '/billing-2','/thank-you-for-your-order')
            AND website_pageviews.website_pageview_id > 53550
    GROUP BY 1) billings ON website_pageviews.website_session_id = billings.session_id
WHERE
    website_pageviews.pageview_url IN ('/billing' , '/billing-2')
    and website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
    and website_pageviews.website_pageview_id > 53550
GROUP BY 1;