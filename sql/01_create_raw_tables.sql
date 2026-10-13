-- 01_create_raw_tables.sql
-- Creates the schemas and raw tables for the KKBox Churn Prediction Challenge data.
-- Run against the kkbox_retention database:
--   psql -h localhost -U kkbox_loader -d kkbox_retention -f sql/01_create_raw_tables.sql
--
-- raw tables mirror the CSV files exactly: same columns, dates kept as YYYYMMDD integers.
-- Cleaning and type conversion happen later in the stg schema.
--
-- Prerequisite (run once as the postgres superuser, e.g. in pgAdmin):
--   CREATE DATABASE kkbox_retention;
--   -- then, connected to kkbox_retention:
--   CREATE ROLE kkbox_loader LOGIN PASSWORD '...';
--   CREATE SCHEMA raw  AUTHORIZATION kkbox_loader;
--   CREATE SCHEMA stg  AUTHORIZATION kkbox_loader;
--   CREATE SCHEMA mart AUTHORIZATION kkbox_loader;

-- members_v3.csv: one row per user
CREATE TABLE IF NOT EXISTS raw.members (
    msno                    TEXT,
    city                    INTEGER,
    bd                      INTEGER,   -- age; contains invalid values such as 0
    gender                  TEXT,
    registered_via          INTEGER,
    registration_init_time  INTEGER    -- YYYYMMDD
);

-- train.csv: churn labels for subscriptions expiring in February 2017
CREATE TABLE IF NOT EXISTS raw.train (
    msno      TEXT,
    is_churn  SMALLINT
);

-- train_v2.csv: churn labels for subscriptions expiring in March 2017
CREATE TABLE IF NOT EXISTS raw.train_v2 (LIKE raw.train);

-- transactions.csv: payment and renewal events up to February 2017
CREATE TABLE IF NOT EXISTS raw.transactions (
    msno                    TEXT,
    payment_method_id       INTEGER,
    payment_plan_days       INTEGER,
    plan_list_price         INTEGER,
    actual_amount_paid      INTEGER,
    is_auto_renew           SMALLINT,
    transaction_date        INTEGER,   -- YYYYMMDD
    membership_expire_date  INTEGER,   -- YYYYMMDD
    is_cancel               SMALLINT
);

-- transactions_v2.csv: payment and renewal events for March 2017
CREATE TABLE IF NOT EXISTS raw.transactions_v2 (LIKE raw.transactions);

-- user_logs.csv: daily listening activity per user, up to February 2017
CREATE TABLE IF NOT EXISTS raw.user_logs (
    msno        TEXT,
    date        INTEGER,           -- YYYYMMDD
    num_25      INTEGER,           -- songs played < 25% of their length
    num_50      INTEGER,           -- 25-50%
    num_75      INTEGER,           -- 50-75%
    num_985     INTEGER,           -- 75-98.5%
    num_100     INTEGER,           -- 98.5-100%
    num_unq     INTEGER,           -- unique songs played
    total_secs  DOUBLE PRECISION   -- total listening seconds
);

-- user_logs_v2.csv: daily listening activity for March 2017
CREATE TABLE IF NOT EXISTS raw.user_logs_v2 (LIKE raw.user_logs);
