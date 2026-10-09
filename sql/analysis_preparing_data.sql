CREATE DATABASE retail_sales_analytics;

USE retail_sales_analytics;
SELECT DATABASE();

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL
);

CREATE TABLE dim_product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    item_type VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dim_geography (
    geography_id INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100) NOT NULL UNIQUE,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE dim_sales_channel (
    sales_channel_id INT AUTO_INCREMENT PRIMARY KEY,
    sales_channel VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE dim_priority (
    priority_id INT AUTO_INCREMENT PRIMARY KEY,
    priority_code CHAR(1) NOT NULL UNIQUE,
    priority_name VARCHAR(30)
);


CREATE TABLE fact_sales (
    sales_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    order_id BIGINT NOT NULL,

    order_date_id INT NOT NULL,
    ship_date_id INT NOT NULL,

    product_id INT NOT NULL,
    geography_id INT NOT NULL,
    sales_channel_id INT NOT NULL,
    priority_id INT NOT NULL,

    units_sold INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,

    total_revenue DECIMAL(18,2) NOT NULL,
    total_cost DECIMAL(18,2) NOT NULL,
    total_profit DECIMAL(18,2) NOT NULL,

    CONSTRAINT fk_order_date
        FOREIGN KEY (order_date_id)
        REFERENCES dim_date(date_id),

    CONSTRAINT fk_ship_date
        FOREIGN KEY (ship_date_id)
        REFERENCES dim_date(date_id),

    CONSTRAINT fk_product
        FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id),

    CONSTRAINT fk_geography
        FOREIGN KEY (geography_id)
        REFERENCES dim_geography(geography_id),

    CONSTRAINT fk_sales_channel
        FOREIGN KEY (sales_channel_id)
        REFERENCES dim_sales_channel(sales_channel_id),

    CONSTRAINT fk_priority
        FOREIGN KEY (priority_id)
        REFERENCES dim_priority(priority_id)
);


describe fact_sales;

show tables;

DESCRIBE dim_date;
DESCRIBE dim_product;
DESCRIBE dim_geography;
DESCRIBE dim_sales_channel;
DESCRIBE dim_priority;

SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_geography;
SELECT COUNT(*) FROM dim_sales_channel;
SELECT COUNT(*) FROM dim_priority;
SELECT COUNT(*) FROM dim_date;


SELECT COUNT(*) AS total_rows
FROM fact_sales;

SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM fact_sales;

SELECT MIN(sales_id) AS first_sales_id,
       MAX(sales_id) AS last_sales_id
FROM fact_sales;


SELECT
    COUNT(*) AS total_orders,
    SUM(units_sold) AS units_sold,
    SUM(total_revenue) AS revenue,
    SUM(total_cost) AS cost,
    SUM(total_profit) AS profit
FROM fact_sales;


SELECT COUNT(*) 
FROM fact_sales;

SELECT
    COUNT(*) AS total_orders,
    SUM(units_sold) AS total_units_sold,
    SUM(total_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(total_profit) AS total_profit,
    ROUND(
        SUM(total_profit) / SUM(total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales;


SELECT
    d.year,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    SUM(f.units_sold) AS units_sold
FROM fact_sales f
JOIN dim_date d
    ON f.order_date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


SELECT
    g.region,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    SUM(f.units_sold) AS units_sold
FROM fact_sales f
JOIN dim_geography g
    ON f.geography_id = g.geography_id
GROUP BY g.region
ORDER BY revenue DESC;


SELECT
    p.item_type,
    SUM(f.units_sold) AS units_sold,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    ROUND(
        SUM(f.total_profit) / SUM(f.total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales f
JOIN dim_product p
    ON f.product_id = p.product_id
GROUP BY p.item_type
ORDER BY profit DESC;



SELECT
    sc.sales_channel,
    COUNT(*) AS orders,
    SUM(f.units_sold) AS units_sold,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    ROUND(
        SUM(f.total_profit) / SUM(f.total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales f
JOIN dim_sales_channel sc
    ON f.sales_channel_id = sc.sales_channel_id
GROUP BY sc.sales_channel
ORDER BY revenue DESC;


SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.units_sold) AS units_sold,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit
FROM fact_sales f
JOIN dim_date d
    ON f.order_date_id = d.date_id
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;
    
    
    
SELECT
    p.item_type,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    ROUND(
        SUM(f.total_profit) / SUM(f.total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales f
JOIN dim_product p
    ON f.product_id = p.product_id
GROUP BY p.item_type
ORDER BY profit_margin DESC;


SELECT
    g.country,
    g.region,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    ROUND(
        SUM(f.total_profit) / SUM(f.total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales f
JOIN dim_geography g
    ON f.geography_id = g.geography_id
GROUP BY
    g.country,
    g.region
ORDER BY revenue DESC
LIMIT 10;


SELECT
    g.region,
    SUM(f.total_revenue) AS revenue,
    ROUND(
        SUM(f.total_revenue) /
        (SELECT SUM(total_revenue) FROM fact_sales) * 100,
        2
    ) AS revenue_share_pct
FROM fact_sales f
JOIN dim_geography g
    ON f.geography_id = g.geography_id
GROUP BY g.region
ORDER BY revenue DESC;


WITH monthly AS (
    SELECT
        d.year,
        d.month,
        MAX(d.month_name) AS month_name,
        SUM(f.units_sold) AS units_sold
    FROM fact_sales f
    JOIN dim_date d
        ON f.order_date_id = d.date_id
    GROUP BY
        d.year,
        d.month
)
SELECT
    month,
    month_name,
    ROUND(AVG(units_sold), 0) AS avg_units_sold,
    MIN(units_sold) AS min_units_sold,
    MAX(units_sold) AS max_units_sold
FROM monthly
GROUP BY
    month,
    month_name
ORDER BY month;



WITH yearly_sales AS (
    SELECT
        d.year,
        SUM(f.total_revenue) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.order_date_id = d.date_id
    GROUP BY d.year
)
SELECT
    year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS previous_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year))
        / LAG(revenue) OVER (ORDER BY year) * 100,
        2
    ) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;


WITH yearly_sales AS (
    SELECT
        d.year,
        SUM(f.total_profit) AS profit
    FROM fact_sales f
    JOIN dim_date d
        ON f.order_date_id = d.date_id
    GROUP BY d.year
)
SELECT
    year,
    profit,
    LAG(profit) OVER (ORDER BY year) AS previous_year_profit,
    ROUND(
        (profit - LAG(profit) OVER (ORDER BY year))
        / LAG(profit) OVER (ORDER BY year) * 100,
        2
    ) AS yoy_profit_growth_pct
FROM yearly_sales
ORDER BY year;


SELECT
    d.year,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    ROUND(
        SUM(f.total_profit) / SUM(f.total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales f
JOIN dim_date d
    ON f.order_date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


SELECT
    g.region,
    s.sales_channel,
    COUNT(*) AS orders,
    SUM(f.total_revenue) AS revenue,
    SUM(f.total_profit) AS profit,
    ROUND(
        SUM(f.total_profit) / SUM(f.total_revenue) * 100,
        2
    ) AS profit_margin
FROM fact_sales f
JOIN dim_geography g
    ON f.geography_id = g.geography_id
JOIN dim_sales_channel s
    ON f.sales_channel_id = s.sales_channel_id
GROUP BY
    g.region,
    s.sales_channel
ORDER BY
    g.region,
    revenue DESC;
    
SELECT
    ROUND(
        AVG(DATEDIFF(ship.full_date, orders.full_date)),
        2
    ) AS avg_shipping_days,
    MIN(DATEDIFF(ship.full_date, orders.full_date)) AS min_shipping_days,
    MAX(DATEDIFF(ship.full_date, orders.full_date)) AS max_shipping_days
FROM fact_sales f
JOIN dim_date orders
    ON f.order_date_id = orders.date_id
JOIN dim_date ship
    ON f.ship_date_id = ship.date_id;
    
    
SELECT
    s.sales_channel,
    COUNT(*) AS orders,
    ROUND(
        AVG(DATEDIFF(ship.full_date, orders.full_date)),
        2
    ) AS avg_shipping_days,
    MIN(DATEDIFF(ship.full_date, orders.full_date)) AS min_shipping_days,
    MAX(DATEDIFF(ship.full_date, orders.full_date)) AS max_shipping_days
FROM fact_sales f
JOIN dim_sales_channel s
    ON f.sales_channel_id = s.sales_channel_id
JOIN dim_date orders
    ON f.order_date_id = orders.date_id
JOIN dim_date ship
    ON f.ship_date_id = ship.date_id
GROUP BY s.sales_channel
ORDER BY avg_shipping_days DESC;


SELECT
    p.priority_code,
    COUNT(*) AS orders,
    ROUND(
        AVG(DATEDIFF(ship.full_date, orders.full_date)),
        2
    ) AS avg_shipping_days,
    MIN(DATEDIFF(ship.full_date, orders.full_date)) AS min_shipping_days,
    MAX(DATEDIFF(ship.full_date, orders.full_date)) AS max_shipping_days
FROM fact_sales f
JOIN dim_priority p
    ON f.priority_id = p.priority_id
JOIN dim_date orders
    ON f.order_date_id = orders.date_id
JOIN dim_date ship
    ON f.ship_date_id = ship.date_id
GROUP BY p.priority_code
ORDER BY avg_shipping_days;


CREATE TABLE monthly_forecast (
    forecast_date DATE PRIMARY KEY,
    forecast_units_sold INT NOT NULL,
    model_name VARCHAR(50) NOT NULL
);


USE retail_sales_analytics;


SELECT COUNT(*) AS total_rows
FROM monthly_forecast;

SELECT *
FROM monthly_forecast;

SELECT
    'Original' AS source,
    COUNT(*) AS total_rows,
    SUM(total_revenue) AS revenue,
    SUM(total_profit) AS profit
FROM fact_sales

UNION ALL

SELECT
    'Clean' AS source,
    COUNT(*) AS total_rows,
    SUM(total_revenue) AS revenue,
    SUM(total_profit) AS profit
FROM fact_sales_clean;
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'retail_sales_analytics'
  AND REFERENCED_TABLE_NAME = 'fact_sales';
SHOW CREATE TABLE fact_sales_clean;

ALTER TABLE fact_sales_clean
ADD CONSTRAINT fk_clean_order_date
FOREIGN KEY (order_date_id)
REFERENCES dim_date(date_id);

ALTER TABLE fact_sales_clean
ADD CONSTRAINT fk_clean_ship_date
FOREIGN KEY (ship_date_id)
REFERENCES dim_date(date_id);

ALTER TABLE fact_sales_clean
ADD CONSTRAINT fk_clean_product
FOREIGN KEY (product_id)
REFERENCES dim_product(product_id);

ALTER TABLE fact_sales_clean
ADD CONSTRAINT fk_clean_geography
FOREIGN KEY (geography_id)
REFERENCES dim_geography(geography_id);

ALTER TABLE fact_sales_clean
ADD CONSTRAINT fk_clean_sales_channel
FOREIGN KEY (sales_channel_id)
REFERENCES dim_sales_channel(sales_channel_id);

ALTER TABLE fact_sales_clean
ADD CONSTRAINT fk_clean_priority
FOREIGN KEY (priority_id)
REFERENCES dim_priority(priority_id);

SHOW CREATE TABLE fact_sales_clean;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(total_revenue) AS total_revenue,
    SUM(total_profit) AS total_profit
FROM fact_sales_clean;

USE retail_sales_analytics;

RENAME TABLE
    fact_sales TO fact_sales_old,
    fact_sales_clean TO fact_sales;
    
SHOW TABLES LIKE 'fact_sales%';
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM retail_sales_analytics.fact_sales;
SELECT 1;
SHOW FULL PROCESSLIST;
KILL QUERY 9;
KILL QUERY 37;
KILL QUERY 39;
SHOW TABLES LIKE 'fact_sales%';
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM fact_sales;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM fact_sales_clean;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(total_revenue) AS total_revenue,
    SUM(total_profit) AS total_profit
FROM retail_sales_analytics.fact_sales;

SHOW CREATE TABLE retail_sales_analytics.fact_sales;

SHOW CREATE TABLE fact_sales;
