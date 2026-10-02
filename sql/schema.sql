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

 -- IF EXISTS so it doesn't fail if the table doesn't exist
-- customers can't be deleted if orders exist since orders references customers table. therefore delete orders first.
-- work backwards when dropping, forward when creating
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sellers;
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
    customer_state CHAR(2)                   -- Fixed two-character Brazilian state code, will pad if only 1 letter provided
);

-- ------------------------------------------------------------
-- Products Table
-- Stores product category, descriptive metadata, physical
-- measurements, and data-quality flags.
-- product_id uniquely identifies each product.
-- Numeric product attributes allow NULL because some products
-- contain missing metadata or measurements in the source data.
-- ------------------------------------------------------------

CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,                    -- Unique identifier for each product
    product_category_name VARCHAR(100) NOT NULL,           -- Original Portuguese product category
    product_name_length INTEGER,                           -- Number of characters in the product name
    product_description_length INTEGER,                    -- Number of characters in the product description
    product_photos_qty INTEGER,                            -- Number of product photos
    product_weight_g INTEGER,                              -- Product weight in grams
    product_length_cm INTEGER,                             -- Product length in centimetres
    product_height_cm INTEGER,                             -- Product height in centimetres
    product_width_cm INTEGER,                              -- Product width in centimetres
    product_metadata_missing BOOLEAN NOT NULL,             -- Flags missing descriptive product metadata
    product_measurements_missing BOOLEAN NOT NULL,         -- Flags missing physical product measurements
    product_category_name_english VARCHAR(100) NOT NULL    -- English product category
);

-- ------------------------------------------------------------
-- Sellers Table
-- Stores seller identifiers and geographic information.
-- seller_id uniquely identifies each seller.
-- ------------------------------------------------------------

CREATE TABLE sellers (
    seller_id VARCHAR(32) PRIMARY KEY,      -- Unique identifier for each seller
    seller_zip_code_prefix INTEGER,         -- First digits of the seller's postal code
    seller_city VARCHAR(100),               -- Seller's city
    seller_state CHAR(2)                    -- Fixed two-character Brazilian state code
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

CREATE TABLE reviews (
    review_id VARCHAR(32) NOT NULL,                    -- Identifier associated with the review
    order_id VARCHAR(32) NOT NULL,                     -- Order associated with the review
    review_score INTEGER NOT NULL,                     -- Customer review score
    review_comment_title VARCHAR(100) NOT NULL,        -- Review title, or "No title" when not provided
    review_comment_message TEXT NOT NULL,              -- Review message, or "No comment" when not provided
    review_creation_date TIMESTAMP NOT NULL,           -- Date the review was created
    review_answer_timestamp TIMESTAMP NOT NULL,        -- Date and time the review was answered

    -- Composite primary key uniquely identifies each review record
    CONSTRAINT pk_reviews
        PRIMARY KEY (review_id, order_id),

    -- Foreign key order_id references order_id from orders table
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ------------------------------------------------------------
-- Payments Table
-- Stores payment information associated with each order.
-- An order can have multiple payment records, so order_id alone
-- is not unique. The combination of order_id and
-- payment_sequential uniquely identifies each payment record.
-- ------------------------------------------------------------

CREATE TABLE payments (
    order_id VARCHAR(32) NOT NULL,             -- Order associated with the payment
    payment_sequential INTEGER NOT NULL,       -- Payment sequence number within the order
    payment_type VARCHAR(20) NOT NULL,         -- Method used to make the payment
    payment_installments INTEGER NOT NULL,     -- Number of payment installments
    payment_value NUMERIC(10, 2) NOT NULL,     -- Payment amount

    -- Composite primary key uniquely identifies each payment within an order
    CONSTRAINT pk_payments
        PRIMARY KEY (order_id, payment_sequential),

    -- Foreign key order_id references order_id from orders table
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
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

    -- A composite primary key using order_id and order_item_id
    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),

    -- Foreign key order_id references order_id from orders TABLE
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),

    -- Foreign key product_id references product_id from products TABLE
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),

    -- Foreign key seller_id references seller_id from sellers table
    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);