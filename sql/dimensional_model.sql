-- ============================================================
-- Retail Business Intelligence & Analytics Platform
-- Dimensional Model
-- Purpose: Create fact and dimension tables for analytics
--          and Power BI reporting.
-- ============================================================

-- ------------------------------------------------------------
-- Date Dimension
-- Grain: One row per calendar date.
-- Provides calendar attributes used for time-based analysis
-- of sales and other business events.
-- ------------------------------------------------------------

-- Remove the existing date dimension if it already exists so the
-- dimensional model can be safely recreated during development.
DROP TABLE IF EXISTS dim_date;

-- Generate one row for every calendar date between the earliest
-- and latest purchase dates in the dataset.
CREATE TABLE dim_date AS
SELECT
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER AS date_key,     -- Integer date identifier in YYYYMMDD format
    date_value::DATE AS full_date,                            -- Full calendar date
    EXTRACT(YEAR FROM date_value)::INTEGER AS year,           -- Calendar year
    EXTRACT(QUARTER FROM date_value)::INTEGER AS quarter,     -- Calendar quarter from 1 to 4
    EXTRACT(MONTH FROM date_value)::INTEGER AS month_number,  -- Calendar month number from 1 to 12
    TO_CHAR(date_value, 'FMMonth') AS month_name,               -- Full month name (FM-Fill mode)
    EXTRACT(DAY FROM date_value)::INTEGER AS day,             -- Day of the month
    TO_CHAR(date_value, 'FMDay') AS day_of_week                 -- Full weekday name (FM-without padding)
FROM GENERATE_SERIES(
    '2016-09-04'::DATE,                                      -- Earliest purchase date
    '2018-10-17'::DATE,                                      -- Latest purchase date
    '1 day'::INTERVAL                                        -- Generate one row for each day
) AS date_value; -- store this series of rows in date_value

-- Each calendar date must occur only once in the dimension.
-- date_key is therefore used as the primary key.
ALTER TABLE dim_date
ADD CONSTRAINT pk_dim_date
PRIMARY KEY (date_key);

-- ------------------------------------------------------------
-- Order Item Fact Table
-- Grain: One row per item within an order.
-- Combines item-level sales data with order information needed
-- for customer and time-based analysis.
-- ------------------------------------------------------------
-- Remove the existing fact table if it already exists so the
-- dimensional model can be safely recreated during development.
DROP TABLE IF EXISTS fact_order_items;

-- Create the fact table from the item-level order records.
-- The orders table is joined because order_items does not contain
-- the customer or purchase timestamp associated with each sale.
CREATE TABLE fact_order_items AS
SELECT
    oi.order_id,                      -- Order containing the item
    oi.order_item_id,                 -- Identifies the item within the order
    o.customer_id,                    -- Customer who placed the order
    oi.product_id,                    -- Product that was purchased
    oi.seller_id,                     -- Seller that fulfilled the item
    TO_CHAR(o.order_purchase_timestamp, 'YYYYMMDD')::INTEGER AS purchase_date_key, -- to match with date_key in dim_date
    o.order_purchase_timestamp,       -- Date and time the order was placed
    oi.price,                         -- Price of the product
    oi.freight_value                  -- Freight charge associated with the item
FROM order_items AS oi
INNER JOIN orders AS o
    ON oi.order_id = o.order_id;      -- Match each item to its parent order

-- Enforce the grain of one row per item within an order.
-- An order can contain multiple items, so neither order_id nor
-- order_item_id is unique by itself. Together they uniquely
-- identify each fact record.
ALTER TABLE fact_order_items
ADD CONSTRAINT pk_fact_order_items
PRIMARY KEY (order_id, order_item_id);

-- Connect each fact row to the calendar date on which the
-- corresponding order was purchased.
-- purchase_date_key is a foreign key that must match an existing
-- date_key in dim_date.
ALTER TABLE fact_order_items
ADD CONSTRAINT fk_fact_order_items_purchase_date
FOREIGN KEY (purchase_date_key)
REFERENCES dim_date(date_key);