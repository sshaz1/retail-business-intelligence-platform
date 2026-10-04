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