-- 02_load_raw_data.sql
-- Loads the KKBox CSV files from data/raw/ into the raw schema.
--
-- Uses psql's client-side \copy, so the files are read by your user rather than the
-- PostgreSQL server process (which may not have access to your home folder).
-- Run from the repository root:
--   psql -h localhost -U kkbox_loader -d kkbox_retention -f sql/02_load_raw_data.sql
--
-- Each table is truncated first, so the script is safe to re-run.
-- user_logs.csv (~28 GB) is loaded last because it takes the longest.

\set ON_ERROR_STOP on
\timing on

\echo 'Loading raw.members ...'
TRUNCATE raw.members;
\copy raw.members FROM 'data/raw/members_v3.csv' WITH (FORMAT csv, HEADER true)

\echo 'Loading raw.train ...'
TRUNCATE raw.train;
\copy raw.train FROM 'data/raw/train.csv' WITH (FORMAT csv, HEADER true)

\echo 'Loading raw.train_v2 ...'
TRUNCATE raw.train_v2;
\copy raw.train_v2 FROM 'data/raw/train_v2.csv' WITH (FORMAT csv, HEADER true)

\echo 'Loading raw.transactions ...'
TRUNCATE raw.transactions;
\copy raw.transactions FROM 'data/raw/transactions.csv' WITH (FORMAT csv, HEADER true)

\echo 'Loading raw.transactions_v2 ...'
TRUNCATE raw.transactions_v2;
\copy raw.transactions_v2 FROM 'data/raw/transactions_v2.csv' WITH (FORMAT csv, HEADER true)

\echo 'Loading raw.user_logs_v2 ...'
TRUNCATE raw.user_logs_v2;
\copy raw.user_logs_v2 FROM 'data/raw/user_logs_v2.csv' WITH (FORMAT csv, HEADER true)

\echo 'Loading raw.user_logs (large, this takes a while) ...'
TRUNCATE raw.user_logs;
\copy raw.user_logs FROM 'data/raw/user_logs.csv' WITH (FORMAT csv, HEADER true)

-- Refresh table statistics so the query planner knows the new table sizes.
ANALYZE raw.members, raw.train, raw.train_v2, raw.transactions, raw.transactions_v2,
        raw.user_logs, raw.user_logs_v2;
\echo 'Done.'
