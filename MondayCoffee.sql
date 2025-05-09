-- Monday Coffee -- Data Analysis

-- View base tables
SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Q1: Coffee Consumers Count
SELECT 
    city_name,
    ROUND((population * 0.25)::numeric / 1000000, 2) AS coffee_consumers_in_millions,
    city_rank
FROM city
ORDER BY 2 DESC;

-- Q2: Total Revenue from Coffee Sales in Q4 2023
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON ci.city_id = c.city_id
WHERE 
    EXTRACT(YEAR FROM s.sale_date) = 2023
    AND EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- Q3: Sales Count for Each Product
SELECT 
    p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM products AS p
LEFT JOIN sales AS s ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC;

-- Q4: Average Sales Amount per Customer in Each City
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND((SUM(s.total) / COUNT(DISTINCT s.customer_id))::numeric, 2) AS avg_sale_pr_cx
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- Q5: City Population vs Actual Coffee Buyers
WITH city_table AS (
    SELECT 
        city_name,
        ROUND((population * 0.25)::numeric / 1000000, 2) AS coffee_consumers
    FROM city
),
customers_table AS (
    SELECT 
        ci.city_name,
        COUNT(DISTINCT c.customer_id) AS unique_cx
    FROM sales AS s
    JOIN customers AS c ON c.customer_id = s.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
)
SELECT 
    ct.city_name,
    cty.coffee_consumers AS coffee_consumer_in_millions,
    ct.unique_cx
FROM city_table cty
JOIN customers_table ct ON cty.city_name = ct.city_name;

-- Q6: Top 3 Selling Products by City
SELECT * FROM (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_orders,
        DENSE_RANK() OVER (PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS rank
    FROM sales AS s
    JOIN products AS p ON s.product_id = p.product_id
    JOIN customers AS c ON c.customer_id = s.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, p.product_name
) AS ranked
WHERE rank <= 3;

-- Q7: Unique Coffee Customers by City
SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cx
FROM city AS ci
JOIN customers AS c ON c.city_id = ci.city_id
JOIN sales AS s ON s.customer_id = c.customer_id
WHERE s.product_id BETWEEN 1 AND 14
GROUP BY ci.city_name;

-- Q8: Average Sale and Rent per Customer
WITH city_sales AS (
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND((SUM(s.total) / COUNT(DISTINCT s.customer_id))::numeric, 2) AS avg_sale_pr_cx
    FROM sales AS s
    JOIN customers AS c ON s.customer_id = c.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
),
city_rent AS (
    SELECT city_name, estimated_rent FROM city
)
SELECT 
    cr.city_name,
    cr.estimated_rent,
    cs.total_cx,
    cs.avg_sale_pr_cx,
    ROUND((cr.estimated_rent / cs.total_cx)::numeric, 2) AS avg_rent_per_cx
FROM city_rent cr
JOIN city_sales cs ON cr.city_name = cs.city_name
ORDER BY avg_sale_pr_cx DESC;

-- Q9: Monthly Sales Growth
WITH monthly_sales AS (
    SELECT 
        ci.city_name,
        EXTRACT(MONTH FROM sale_date) AS month,
        EXTRACT(YEAR FROM sale_date) AS year,
        SUM(s.total) AS total_sale
    FROM sales AS s
    JOIN customers AS c ON c.customer_id = s.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, year, month
),
growth AS (
    SELECT 
        city_name,
        month,
        year,
        total_sale AS cr_month_sale,
        LAG(total_sale) OVER (PARTITION BY city_name ORDER BY year, month) AS last_month_sale
    FROM monthly_sales
)
SELECT 
    city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    ROUND(((cr_month_sale - last_month_sale) / NULLIF(last_month_sale, 0))::numeric, 2) AS growth_ratio
FROM growth
WHERE last_month_sale IS NOT NULL;

-- Q10: Market Potential Analysis
WITH city_sales AS (
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND((SUM(s.total) / COUNT(DISTINCT s.customer_id))::numeric, 2) AS avg_sale_pr_cx
    FROM sales AS s
    JOIN customers AS c ON s.customer_id = c.customer_id
    JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
),
city_info AS (
    SELECT 
        city_name,
        estimated_rent,
        ROUND((population * 0.25)::numeric / 1000000, 3) AS estimated_coffee_consumer_in_millions
    FROM city
)
SELECT 
    ci.city_name,
    cs.total_revenue,
    ci.estimated_rent AS total_rent,
    cs.total_cx,
    ci.estimated_coffee_consumer_in_millions,
    cs.avg_sale_pr_cx,
    ROUND((ci.estimated_rent / cs.total_cx)::numeric, 2) AS avg_rent_per_cx
FROM city_info ci
JOIN city_sales cs ON ci.city_name = cs.city_name
ORDER BY total_revenue DESC;
