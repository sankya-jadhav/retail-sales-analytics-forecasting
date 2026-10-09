USE retail_sales_analytics;

-- 1. Overall business KPIs
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(units_sold) AS total_units_sold,
    SUM(total_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(total_profit) AS total_profit,
    ROUND(
        SUM(total_profit) / NULLIF(SUM(total_revenue), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales;

-- 2. Revenue and profit by region
SELECT
    g.region,
    SUM(f.total_revenue) AS total_revenue,
    SUM(f.total_profit) AS total_profit
FROM fact_sales f
JOIN dim_geography g
    ON f.geography_id = g.geography_id
GROUP BY g.region
ORDER BY total_revenue DESC;

-- 3. Revenue and profit by product
SELECT
    p.item_type,
    SUM(f.total_revenue) AS total_revenue,
    SUM(f.total_profit) AS total_profit,
    ROUND(
        SUM(f.total_profit) / NULLIF(SUM(f.total_revenue), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales f
JOIN dim_product p
    ON f.product_id = p.product_id
GROUP BY p.item_type
ORDER BY total_revenue DESC;

-- 4. Performance by sales channel
SELECT
    sc.sales_channel,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.total_revenue) AS total_revenue,
    SUM(f.total_profit) AS total_profit
FROM fact_sales f
JOIN dim_sales_channel sc
    ON f.sales_channel_id = sc.sales_channel_id
GROUP BY sc.sales_channel
ORDER BY total_revenue DESC;

-- 5. Top 10 countries by revenue
SELECT
    g.country,
    g.region,
    SUM(f.total_revenue) AS total_revenue,
    SUM(f.total_profit) AS total_profit
FROM fact_sales f
JOIN dim_geography g
    ON f.geography_id = g.geography_id
GROUP BY g.country, g.region
ORDER BY total_revenue DESC
LIMIT 10;