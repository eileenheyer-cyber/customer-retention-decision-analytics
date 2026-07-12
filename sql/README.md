# SQL

**Status: Planned / In Progress.** No SQL scripts have been written yet.

## What Belongs Here

- SQL scripts for creating database schemas/tables in PostgreSQL.
- Data extraction and transformation queries used to build the customer-level analytical dataset.
- Queries used to validate data quality (e.g., null checks, duplicate checks, referential integrity).
- Queries supporting exploratory analysis, where SQL is a more natural fit than Python.

## What Should Not Be Stored Here

- Database credentials, connection strings, or `.env` files (see repository `.gitignore`).
- Local database files (e.g., `.db`, `.sqlite` files) — these should never be committed.
- Large query result exports — save summarized outputs in `reports/` instead, not raw query dumps.

## Naming Conventions

- Prefix scripts by purpose and order of execution, e.g., `01_create_schema.sql`, `02_load_raw_data.sql`, `03_build_customer_features.sql`.
- Use lowercase, underscore-separated names.
- Group related queries into clearly named subfolders if the number of scripts grows large (e.g., `sql/etl/`, `sql/validation/`).