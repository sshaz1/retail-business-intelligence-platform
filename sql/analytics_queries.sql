-- Calculate high-level sales KPIs across all order items.
-- Because fact_order_items has a grain of one row per item
-- within an order, COUNT(*) represents the total number of
-- order-item records sold.
--
-- COUNT(DISTINCT order_id) counts each order only once,
-- preventing multi-item orders from being counted multiple times.
--
-- SUM(price) calculates the total merchandise sales value
-- across all order items. Freight charges are excluded from
-- this measure and analyzed separately.
--
-- Average merchandise value per order divides total merchandise
-- sales by the number of distinct orders represented in the
-- item-level fact table.
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    SUM(price) AS total_merchandise_sales,
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS avg_merchandise_value_per_order
FROM fact_order_items;

-- ------------------------------------------------------------
-- Sales Trends
-- ------------------------------------------------------------

-- Analyze merchandise sales and order activity by calendar year.
-- The fact table is joined to dim_date using purchase_date_key
-- so sales can be grouped using calendar attributes from the
-- date dimension.
SELECT
    d.year,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    SUM(f.price) AS total_merchandise_sales
FROM fact_order_items AS f
INNER JOIN dim_date AS d
    ON f.purchase_date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- Analyze merchandise sales and order activity by month.
-- Grouping by both year and month keeps months from different
-- years separate and allows sales trends to be viewed over time.
SELECT
    d.year,
    d.month_number,
    d.month_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    SUM(f.price) AS total_merchandise_sales
FROM fact_order_items AS f
INNER JOIN dim_date AS d
    ON f.purchase_date_key = d.date_key
GROUP BY
    d.year,
    d.month_number,
    d.month_name
ORDER BY
    d.year,
    d.month_number;

-- ------------------------------------------------------------
-- Product Performance
-- ------------------------------------------------------------

-- Analyze sales performance by product category.
-- fact_order_items provides the sales measures while products
-- provides descriptive information about each product.
SELECT
    p.product_category_name_english AS product_category,
    COUNT(*) AS total_items_sold,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.price) AS total_merchandise_sales
FROM fact_order_items AS f
INNER JOIN products AS p
    ON f.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY total_merchandise_sales DESC; -- can use this alias here because SELECT output runs first than it gets ordered

-- Compare average item prices across product categories.
-- This helps explain why categories with fewer items sold can
-- still generate high merchandise sales.
SELECT
    p.product_category_name_english AS product_category,
    COUNT(*) AS total_items_sold,
    ROUND(AVG(f.price), 2) AS avg_item_price,
    SUM(f.price) AS total_merchandise_sales
FROM fact_order_items AS f
INNER JOIN products AS p
    ON f.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY avg_item_price DESC;

-- ------------------------------------------------------------
-- Customer & Geographic Analysis
-- ------------------------------------------------------------

-- Analyze order activity by customer state.
-- customers provides the geographic information while orders
-- provides one row per customer order.
SELECT
    c.customer_state,
    COUNT(*) AS total_orders
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

-- ------------------------------------------------------------
-- Delivery Performance
-- ------------------------------------------------------------

-- Analyze the number of orders in each delivery status.
-- The orders table is used because its grain is one row per order,
-- preventing delivery metrics from being duplicated across items.
-- Calculate the percentage of all orders in each delivery status.
-- Multiplying by 100 converts the proportion into a percentage.
-- The empty OVER() means the calculation uses all rows in the result while keeping the individual rows
SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_orders
FROM orders
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- Calculate the late-delivery rate using only orders with
-- known delivery outcomes.
SELECT
    COUNT(*) FILTER (WHERE delivery_status = 'Late') AS late_orders,
    COUNT(*) FILTER (WHERE delivery_status != 'Missing Delivery Data') AS orders_with_delivery_data,
    ROUND(
        COUNT(*) FILTER (WHERE delivery_status = 'Late') * 100.0 /
        COUNT(*) FILTER (WHERE delivery_status != 'Missing Delivery Data'),
        2
    ) AS late_delivery_rate
FROM orders;

-- Compare average and median delivery times.
-- The median is less affected by unusually long deliveries
-- and gives a better picture of a typical order.
-- PERCENTILE_CONT(0.5) means find the 50th percentile, which is the median.
SELECT
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_days) AS median_delivery_days,
    MIN(delivery_days) AS fastest_delivery_days,
    MAX(delivery_days) AS slowest_delivery_days
FROM orders
WHERE delivery_days IS NOT NULL;