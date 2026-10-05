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

![PostgreSQL Connection](screenshots/postgresql_connection.png)

## Data Selection

The initial Power BI model imports:

- `customers`
- `dim_date`
- `fact_order_items`
- `orders`
- `products`
- `sellers`

`order_items` is not imported because the required item-level sales data is already represented by `fact_order_items`.

![Power BI Data Selection](screenshots/data_selection.png)

## Power Query

*To be documented as the project progresses.*

## Data Model

*To be documented as the project progresses.*

## DAX Measures

*To be documented as the project progresses.*

## Dashboard

*To be documented as the project progresses.*