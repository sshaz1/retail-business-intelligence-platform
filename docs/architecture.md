# Retail Business Intelligence & Analytics Platform — Architecture

## Overview

This project transforms raw Olist e-commerce data into a structured analytics platform for retail business intelligence and decision support.

The pipeline follows this general architecture:

```text
Raw Olist CSV Data
        ↓
Python / Pandas
Data Cleaning & Transformation
        ↓
Processed CSV Data
        ↓
PostgreSQL
Relational Database
        ↓
Dimensional / Star Schema
        ↓
Power BI
Data Model & DAX
        ↓
Dashboards, KPIs & Business Insights
```

## Dimensional Modelling

Dimensional modelling reorganizes relational data into structures designed for analytics and reporting.

The model separates measurable business events into **fact tables** and descriptive information used to analyze those events into **dimension tables**.

### Facts and Dimensions

**Fact tables** represent measurable business events or processes, such as:

- Product sales
- Orders
- Freight charges
- Delivery performance

**Dimension tables** provide descriptive context for analyzing those events, such as:

- Dates
- Customers
- Products
- Sellers

A useful way to distinguish them is:

> **Facts describe what happened and what can be measured.**  
> **Dimensions describe who, what, where, or when the event relates to.**

Rather than simply copying the existing relational tables, dimensional tables are created when they provide a useful structure for analytics.

---

## Sales Fact Table — `fact_order_items`

The first fact table represents the **product sales** business process.

### Grain

The grain of `fact_order_items` is:

> **One row per item within an order.**

An order containing three items therefore produces three rows in the fact table.

The combination of `order_id` and `order_item_id` uniquely identifies each fact record and is used as the table's composite primary key.

### Source Tables

The fact table is created primarily from the relational `order_items` table.

However, `order_items` does not contain the customer who placed the order or the date and time when the order was purchased.

Therefore, `order_items` is joined to `orders` using `order_id`.

```text
order_items                         orders
-----------                         ------
order_id ────────────────────────── order_id
order_item_id                       customer_id
product_id                          order_purchase_timestamp
seller_id
price
freight_value

                    ↓ INNER JOIN ↓

               fact_order_items
```

Before creating the fact table, the join was validated to ensure that it:

- Preserved all 112,650 order-item records.
- Did not create duplicate `order_id` and `order_item_id` combinations.
- Maintained the intended grain of one row per item within an order.

### Current Structure

```text
fact_order_items
------------------------
order_id
order_item_id
customer_id
product_id
seller_id
order_purchase_timestamp
price
freight_value
```

### Identifiers

- `order_id` — Identifies the order containing the item.
- `order_item_id` — Identifies the item within the order.

Together, these columns form the composite primary key.

### Descriptive Keys

- `customer_id` — Identifies the customer who placed the order.
- `product_id` — Identifies the product that was purchased.
- `seller_id` — Identifies the seller that fulfilled the item.

These identifiers can later connect the fact table to analytical dimensions as the dimensional model develops.

### Measures

- `price` — Price of the product.
- `freight_value` — Freight/shipping charge associated with the item.

Additional measures can later be calculated from these base values in Power BI using DAX.

### Purchase Timestamp

`order_purchase_timestamp` is currently included in the fact table because it identifies when the sale occurred.

As the dimensional model develops, the purchase date will be connected to a dedicated `dim_date` table. This will provide consistent calendar attributes for time-based analysis.

---

## Date Dimension — `dim_date`

The `dim_date` table will provide a dedicated calendar structure for analyzing sales over time.

Unlike the relational source tables, the Olist dataset does not contain a dedicated date table. The date dimension will therefore be generated from the date range contained in the order data.

### Grain

The grain of `dim_date` will be:

> **One row per calendar date.**

For example:

```text
date_key | full_date  | year | quarter | month_number | month_name
---------|------------|------|---------|--------------|-----------
20170913 | 2017-09-13 | 2017 |    3    |      9       | September
20170914 | 2017-09-14 | 2017 |    3    |      9       | September
```

### Purpose

The date dimension will allow sales to be analyzed consistently by calendar attributes such as:

- Year
- Quarter
- Month
- Month name
- Day
- Day of week

This supports analyses such as monthly sales trends, quarterly performance, yearly comparisons, and sales by day of week.

### Relationship to the Sales Fact

The purchase date associated with each order item will eventually connect `fact_order_items` to `dim_date`.

```text
              dim_date
                  |
                  | date_key
                  |
          fact_order_items
```

The dimensional model will continue to evolve as additional analytical requirements are introduced.