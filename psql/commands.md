# psql Command Reference

This file documents the PostgreSQL `psql` commands used while building the Retail Business Intelligence & Analytics Platform.

`psql` commands begin with a backslash (`\`) and are commands provided by the PostgreSQL command-line client rather than standard SQL.

## Connecting to PostgreSQL

From PowerShell:

`psql -U postgres`

- `psql` starts the PostgreSQL command-line client.
- `-U postgres` connects using the `postgres` database user.

### Disable Paginated Output

`\pset pager off`

Disables the psql pager so long query results and table descriptions are printed directly to the terminal instead of pausing with `-- More --`.

### Exit psql

`\q`

Exits the psql command-line client and returns to the regular terminal.

## Database Commands

### List Databases

`\l`

or:

`\list`

Displays all databases on the PostgreSQL server.

### Connect to a Database

`\c retail_bi`

Connects to the `retail_bi` database.

The prompt changes from:

`postgres=#`

to:

`retail_bi=#`

### List Tables

`\dt`

Displays the tables in the currently connected database.

### Describe a Table

`\d customers`

Displays the columns, data types, indexes, and constraints for the `customers` table.

### Execute a SQL File

`\i 'D:/Documents/Career/Projects/retail-business-intelligence-platform/sql/schema.sql'`

Executes the SQL statements stored in `schema.sql`.

## Loading processed Data
```text
\copy table_name FROM 'file_path' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
```

- `\copy` — Imports data from a file on the local computer into PostgreSQL.
- `table_name` — The PostgreSQL table where the data will be inserted.
- `FROM 'file_path'` — Specifies the location of the file being imported.
- `FORMAT csv` — Tells PostgreSQL that the file uses CSV (Comma-Separated Values) format.
- `HEADER true` — Tells PostgreSQL that the first row contains column names and should not be imported as data.
- `ENCODING 'UTF8'` — Tells PostgreSQL to interpret the file using UTF-8 encoding, which supports accented and special characters.

### SQL Syntax Order vs. Logical Execution Order

SQL has two different orders to understand:

- **Syntax order** — the order SQL clauses are written.
- **Logical execution order** — the order PostgreSQL conceptually processes those clauses.

| Order | Syntax / Written Order | Logical Execution Order |
|---|---|---|
| 1 | `SELECT` | `FROM` |
| 2 | `FROM` | `JOIN / ON` |
| 3 | `JOIN / ON` | `WHERE` |
| 4 | `WHERE` | `GROUP BY` |
| 5 | `GROUP BY` | `HAVING` |
| 6 | `HAVING` | `SELECT` |
| 7 | `ORDER BY` | `ORDER BY` |
| 8 | `LIMIT` | `LIMIT` |

### Syntax Order

This is how the query is written:

```sql
SELECT ...
FROM ...
JOIN ... ON ...
WHERE ...
GROUP BY ...
HAVING ...
ORDER BY ...
LIMIT ...;
```

### Logical Execution Order

This is how to think about PostgreSQL processing the query:

```text
FROM
  ↓
JOIN / ON
  ↓
WHERE
  ↓
GROUP BY
  ↓
HAVING
  ↓
SELECT
  ↓
ORDER BY
  ↓
LIMIT
```

The main thing to remember is that `SELECT` is **written first**, but logically processed after PostgreSQL determines the tables, joins, filters, and groups.

## Validating Loaded Data

After importing data into PostgreSQL, validation queries are used to confirm that the data was loaded correctly.

### Count Rows

Use `COUNT(*)` to check the total number of rows in a table:

```sql
SELECT COUNT(*) FROM geolocation;
```

- `SELECT` — Retrieves data from the database.
- `COUNT(*)` — Counts every row in the table.
- `FROM geolocation` — Specifies the table being counted.

The result can be compared with the number of rows in the processed CSV to confirm that all records were imported.

### Preview Data

Use `LIMIT` to inspect a small number of rows:

```sql
SELECT * FROM geolocation LIMIT 5;
```

- `SELECT *` — Retrieves all columns.
- `FROM geolocation` — Specifies the table to retrieve data from.
- `LIMIT 5` — Returns only the first 5 rows.

Previewing the data helps confirm that the values were imported into the correct columns and appear as expected.

## Database Integrity Checks

After loading the processed data, integrity checks are used to confirm that relationships between tables are valid.

### Check for Orphaned Orders

Checks whether any orders reference a customer that does not exist.

```sql
SELECT COUNT(*) AS orphaned_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

- `LEFT JOIN` keeps every order and attempts to find its matching customer.
- `o` and `c` are aliases for the `orders` and `customers` tables.
- `WHERE c.customer_id IS NULL` finds orders that did not match a customer.
- The expected result is `0` because our foreign key already enforced this relationship during loading.

### Check Order Item Relationships

Checks whether every order item has a valid order, product, and seller.

```sql
SELECT
    COUNT(*) FILTER (WHERE o.order_id IS NULL) AS missing_orders,
    COUNT(*) FILTER (WHERE p.product_id IS NULL) AS missing_products,
    COUNT(*) FILTER (WHERE s.seller_id IS NULL) AS missing_sellers
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN sellers s ON oi.seller_id = s.seller_id;
```
A `LEFT JOIN` keeps every row from the table on the left and searches for a matching row in the table on the right. For example:

```sql
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
```
takes every order item and searches for an order with the same `order_id`.
If no matching order exists, the columns from `orders` become `NULL`.

All three results should be `0`.

### Check Geolocation Coverage

Checks how many customer and seller ZIP codes do not have a matching record in the geolocation table.

```sql
SELECT COUNT(*) AS customers_without_geolocation
FROM customers c
LEFT JOIN geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;
```

Expected result: `278`

```sql
SELECT COUNT(*) AS sellers_without_geolocation
FROM sellers s
LEFT JOIN geolocation g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;
```

Expected result: `7`

These unmatched ZIP codes are why customer and seller ZIP prefixes were not defined as foreign keys to the geolocation table.

## Creating a Date Dimension with `GENERATE_SERIES()`

A date dimension provides calendar information that can be used for time-based analysis in a dimensional model.

The following command creates `dim_date` by generating every calendar date between the earliest and latest purchase dates in the dataset.

```sql
CREATE TABLE dim_date AS
SELECT
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER AS date_key,
    date_value::DATE AS full_date,
    EXTRACT(YEAR FROM date_value)::INTEGER AS year,
    EXTRACT(QUARTER FROM date_value)::INTEGER AS quarter,
    EXTRACT(MONTH FROM date_value)::INTEGER AS month_number,
    TO_CHAR(date_value, 'Month') AS month_name,
    EXTRACT(DAY FROM date_value)::INTEGER AS day,
    TO_CHAR(date_value, 'Day') AS day_of_week
FROM GENERATE_SERIES(
    '2016-09-04'::DATE,
    '2018-10-17'::DATE,
    '1 day'::INTERVAL
) AS date_value;
```

### `CREATE TABLE ... AS`

```sql
CREATE TABLE dim_date AS
SELECT ...
```

`CREATE TABLE ... AS` creates a new table using the results returned by a `SELECT` query.

In this case, PostgreSQL generates and transforms a series of dates, then stores the results in a new table called `dim_date`.

---

### `GENERATE_SERIES()`

```sql
GENERATE_SERIES(
    '2016-09-04'::DATE,
    '2018-10-17'::DATE,
    '1 day'::INTERVAL
)
```

`GENERATE_SERIES()` generates a sequence of values.

The three arguments specify:

1. The starting value.
2. The ending value.
3. How much to increase the value each time.

In this example:

```text
Start:     2016-09-04
End:       2018-10-17
Increment: 1 day
```

PostgreSQL therefore generates:

```text
2016-09-04
2016-09-05
2016-09-06
2016-09-07
...
2018-10-17
```

```sql
AS date_value
```

gives each generated date the name `date_value`, which can then be referenced by the `SELECT` statement.

---

### PostgreSQL Type Casting with `::`

The `::` operator converts a value to another PostgreSQL data type.

For example:

```sql
'2016-09-04'::DATE
```

converts the text value into a `DATE`.

```sql
'1 day'::INTERVAL
```

converts the text into a PostgreSQL time interval.

```sql
TO_CHAR(date_value, 'YYYYMMDD')::INTEGER
```

converts the formatted date text into an integer.

General syntax:

```sql
value::data_type
```

---

### `EXTRACT()`

`EXTRACT()` retrieves a specific part of a date or timestamp.

General syntax:

```sql
EXTRACT(part FROM date_value)
```

Examples:

```sql
EXTRACT(YEAR FROM date_value)
EXTRACT(QUARTER FROM date_value)
EXTRACT(MONTH FROM date_value)
EXTRACT(DAY FROM date_value)
```

For the date:

```text
2017-09-13
```

these produce:

```text
YEAR     → 2017
QUARTER  → 3
MONTH    → 9
DAY      → 13
```

The results are converted to integers using:

```sql
::INTEGER
```

---

### `TO_CHAR()`

`TO_CHAR()` converts a date or timestamp into formatted text.

General syntax:

```sql
TO_CHAR(date_value, 'format')
```

Examples:

```sql
TO_CHAR(date_value, 'YYYYMMDD')
```

converts:

```text
2017-09-13 → 20170913
```

while:

```sql
TO_CHAR(date_value, 'Month')
```

produces:

```text
September
```

and:

```sql
TO_CHAR(date_value, 'Day')
```

produces:

```text
Wednesday
```

`EXTRACT()` is useful when a numeric part of a date is needed, while `TO_CHAR()` is useful when the date needs to be formatted as readable text.

---

### Result

A generated date such as:

```text
2017-09-13
```

is transformed into a row containing:

```text
date_key | full_date  | year | quarter | month_number | month_name | day | day_of_week
---------|------------|------|---------|--------------|------------|-----|------------
20170913 | 2017-09-13 | 2017 |    3    |      9       | September  | 13  | Wednesday
```

This gives the dimensional model reusable calendar attributes for analyzing business metrics by year, quarter, month, date, and day of the week.