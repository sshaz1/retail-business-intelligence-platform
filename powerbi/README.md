# Power BI

Power BI is used as the reporting and visualization layer for the Retail Business Intelligence & Analytics Platform.

## Data Pipeline

```text
PostgreSQL → Power Query → Data Model → DAX → Dashboard
```

## PostgreSQL Connection

Power BI connects directly to the local `retail_bi` PostgreSQL database using **Import mode**.

```text
Server: localhost
Database: retail_bi
Connectivity Mode: Import
```

The local development connection uses an unencrypted `localhost` connection. Production environments should use properly configured TLS encryption.

![PostgreSQL Connection](../screenshots/postgresql_connection.png)

## Data Selection

The initial Power BI model imports:

- `customers`
- `dim_date`
- `fact_order_items`
- `orders`
- `products`
- `sellers`

`order_items` is not imported because the required item-level sales data is already represented by `fact_order_items`.

![Power BI Data Selection](../screenshots/data_selection.png)

## Data Model Relationships

Power BI relationships allow filters and calculations to work across related tables.

```text
products.product_id (1) → (*) fact_order_items.product_id
```

This is a **one-to-many relationship** with **single-direction filtering** from the dimension to the fact table.

![Product Relationship](../screenshots/product_relationship.png)

This Power BI model uses five active relationships:

| From (1) | To (*) |
|---|---|
| `products.product_id` | `fact_order_items.product_id` |
| `sellers.seller_id` | `fact_order_items.seller_id` |
| `dim_date.date_key` | `fact_order_items.purchase_date_key` |
| `orders.order_id` | `fact_order_items.order_id` |
| `customers.customer_id` | `orders.customer_id` (1:1) |

Relationships enable filtering across customers, orders, products, sellers, and sales while avoiding duplicate filtering paths.

![Power BI Data Model](../screenshots/power_bi_data_model.png)

**Customer Relationship Note:** In the Olist dataset, `customer_id` is unique to each order's customer record, making the Customers → Orders relationship 1:1. However, `customer_unique_id` identifies the same real customer across multiple orders and is used for repeat-customer analysis.

## Power Query

Created a `purchase_date` column in the `orders` table by duplicating `order_purchase_timestamp` and converting it to **Date Only**.

- **Original:** `2017-10-02 10:56:33`
- **Transformed:** `2017-10-02`

This preserves the original timestamp while providing a date-only column for daily reporting. The transformation is automatically reapplied during data refreshes.

![Power Query Purchase Date Transformation](../screenshots/power_query_purchase_date.png)

## Data Model

*To be documented as the project progresses.*

## DAX Measures
```dax
Total Merchandise Sales = SUM('public fact_order_items'[price])
```
- `SUM()` calculates the total of the `price` column.
This measure represents merchandise sales, excluding freight charges.
- **Validated result:** 13,591,643.70, matching our PostgreSQL analysis.

```dax
Total Orders = DISTINCTCOUNT('public fact_order_items'[order_id])
```
- Counts unique orders without double-counting items.
- **Validated SQL result:** 98,666 orders.

```dax
Average Order Value = DIVIDE([Total Merchandise Sales], [Total Orders])
```
- Calculates average merchandise sales per order using existing measures.
- **Validated SQL result:** 137.75.

```dax
Late Delivery Rate =
DIVIDE(
    CALCULATE(COUNTROWS('public orders'), 'public orders'[delivery_status] = "Late"),
    CALCULATE(COUNTROWS('public orders'), 'public orders'[delivery_status] <> "Missing Delivery Data")
)
```
- Calculates the percentage of late orders, excluding missing delivery data.
- `COUNTROWS()` counts the rows in a table.
- `CALCULATE(what_to_calculate, filter_conditions)` evaluates an expression using specified filters.
- `<>` == not equal to
- **Validated SQL result:** 6.77%.

```dax
Average Delivery Time = AVERAGE('public orders'[delivery_days])
```
- Calculates the average number of days between purchase and delivery.
- `AVERAGE()` calculates the mean of a numeric column, excluding blanks.
- **Validated SQL result:** 12.09 days.

```dax
Total Items Sold = COUNTROWS('public fact_order_items')
```
- Counts the total number of items sold across all orders.
- **Validated SQL result:** 112,650 items.

### Monthly Merchandise Sales

- Line chart showing merchandise sales by year, quarter, and month.
- Uses `dim_date.full_date` and the `Total Merchandise Sales` DAX measure.
- Highlights monthly sales trends across the dataset.

![Monthly Sales Trend](../screenshots/monthly_sales_trend.png)

### Top 10 Product Categories by Sales

- Horizontal bar chart ranking the 10 highest-selling product categories.
- Uses `products.product_category_name_english` and the `Total Merchandise Sales` DAX measure.
- Applies a Top N filter to identify leading categories.

![Top 10 Product Categories by Sale](../screenshots/top_product_categories.png)

### Average Delivery Time by State

- Horizontal bar chart comparing average delivery time (days) across Brazilian states.
- Uses `customers.customer_state` and the `Average Delivery Time` DAX measure.
- Applied a visual-level filter of `Order Count >= 100` to exclude states with fewer than 100 orders, reducing misleading comparisons caused by small sample sizes.

![Average Delivery Time by State](../screenshots/average_delivery_time_by_state.png)

## Dashboard

*To be documented as the project progresses.*