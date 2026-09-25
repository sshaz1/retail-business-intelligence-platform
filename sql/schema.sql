-- ============================================================
-- Retail Business Intelligence & Analytics Platform
-- Database Schema
-- Purpose: Define PostgreSQL tables for the cleaned Olist data
-- ============================================================

-- ------------------------------------------------------------
-- Reset Existing Tables
-- Drop tables before recreating the schema so this script can
-- be safely rerun during development.
-- Child tables must be dropped before their parent tables
-- because of foreign key relationships.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS orders; -- IF EXISTS so it doesn't fail if the table doesn't exist
-- customers can't be deleted if orders exist since orders references customers table. therefore delete orders first.
-- work backwards when dropping, forward when creating
DROP TABLE IF EXISTS customers;


-- ------------------------------------------------------------
-- Customers Table
-- Stores customer identifiers and geographic information.
-- customer_id identifies a customer record associated with an order.
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,     -- Unique identifier for each customer record
    customer_unique_id VARCHAR(32) NOT NULL, -- Identifier used to recognize the same customer across orders, NOT NULL refuses a row where variable is missing
    customer_zip_code_prefix INTEGER,        -- First digits of the customer's postal code
    customer_city VARCHAR(100),              -- Customer's city
    customer_state CHAR(2)                   -- Two-character Brazilian state code, CHAR to add padding incase the its just 1 letter
);

-- ------------------------------------------------------------
-- Orders Table
-- Stores each order and its lifecycle timestamps.
-- customer_id links each order to a record in the customers table.
-- Derived fields support delivery performance analysis.
-- ------------------------------------------------------------

CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,                         -- Unique identifier for each order
    customer_id VARCHAR(32) NOT NULL,                         -- Customer record associated with the order
    order_status VARCHAR(20) NOT NULL,                        -- Current/final status of the order
    order_purchase_timestamp TIMESTAMP NOT NULL,              -- Date and time the order was placed
    order_approved_at TIMESTAMP,                              -- Date and time payment/order was approved
    order_delivered_carrier_date TIMESTAMP,                   -- Date and time the order was handed to the carrier
    order_delivered_customer_date TIMESTAMP,                  -- Date and time the customer received the order
    order_estimated_delivery_date TIMESTAMP,                  -- Estimated customer delivery date
    approval_date_missing BOOLEAN NOT NULL,                   -- Flags missing approval timestamp
    carrier_date_missing BOOLEAN NOT NULL,                    -- Flags missing carrier timestamp
    delivery_date_missing BOOLEAN NOT NULL,                   -- Flags missing customer delivery timestamp
    delivered_order_data_incomplete BOOLEAN NOT NULL,         -- Flags delivered orders with incomplete lifecycle data
    delivery_days INTEGER,                                    -- Days between purchase and actual delivery
    delivery_vs_estimate_days INTEGER,                        -- Days early (-) or late (+) compared with estimate
    delivery_status VARCHAR(25) NOT NULL,                     -- Early, On Time, Late, or Missing Delivery Data

    -- Creating relationship between customer_id in orders with customer_id in customers table
    -- customer_id is the foreign key in orders, primary key being customer_id in customers table
    -- Foreign key from orders to customers.
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ------------------------------------------------------------
-- Order Items Table
-- Stores the individual products contained within each order.
-- An order can contain multiple items, so order_id alone is not unique.
-- The combination of order_id and order_item_id uniquely identifies
-- each item within an order.
-- ------------------------------------------------------------

CREATE TABLE order_items (
    order_id VARCHAR(32) NOT NULL,             -- Order containing the item
    order_item_id INTEGER NOT NULL,            -- Item number within the order
    product_id VARCHAR(32) NOT NULL,            -- Product that was purchased
    seller_id VARCHAR(32) NOT NULL,             -- Seller responsible for the item
    shipping_limit_date TIMESTAMP NOT NULL,     -- Seller's shipping deadline
    price NUMERIC(10, 2) NOT NULL,              -- Product price
    freight_value NUMERIC(10, 2) NOT NULL,      -- Freight/shipping charge

    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);