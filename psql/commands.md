# psql Command Reference

This file documents the PostgreSQL `psql` commands used while building the Retail Business Intelligence & Analytics Platform.

`psql` commands begin with a backslash (`\`) and are commands provided by the PostgreSQL command-line client rather than standard SQL.

## Connecting to PostgreSQL

From PowerShell:

`psql -U postgres`

- `psql` starts the PostgreSQL command-line client.
- `-U postgres` connects using the `postgres` database user.

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

`\i 'D:/sql/schema.sql'`

Executes the SQL statements stored in `schema.sql`.