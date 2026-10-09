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

