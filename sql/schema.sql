-- ============================================================
-- Retail Business Intelligence & Analytics Platform
-- Database Schema
-- Purpose: Define PostgreSQL tables for the cleaned Olist data
-- ============================================================


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