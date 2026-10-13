# Data Dictionary

**Status: Raw layer documented.** This document describes every table and field in the KKBox Churn Prediction Challenge dataset as loaded into the `raw` schema of the `kkbox_retention` PostgreSQL database. Value ranges and missing rates were profiled directly from the loaded data. Cleaned (`stg`) and analysis-ready (`mart`) tables will be added as they are built.

For how the data is downloaded and loaded, see [data/README.md](../data/README.md). Table definitions are in [sql/01_create_raw_tables.sql](../sql/01_create_raw_tables.sql).

---

## Overview

| Table | Source file | Grain | Rows | Period |
|-------|-------------|-------|------|--------|
| `raw.members` | `members_v3.csv` | One row per user | 6,769,473 | Registrations 2004-03-26 to 2017-04-29 |
| `raw.train` | `train.csv` | One row per labelled user | 992,931 | Subscriptions expiring February 2017 |
| `raw.train_v2` | `train_v2.csv` | One row per labelled user | 970,960 | Subscriptions expiring March 2017 |
| `raw.transactions` | `transactions.csv` | One row per transaction | 21,547,746 | 2015-01-01 to 2017-02-28 |
| `raw.transactions_v2` | `transactions_v2.csv` | One row per transaction | 1,431,009 | 2015-01-01 to 2017-03-31 (75% in March 2017) |
| `raw.user_logs` | `user_logs.csv` | One row per user per day | 392,106,543 | 2015-01-01 to 2017-02-28 |
| `raw.user_logs_v2` | `user_logs_v2.csv` | One row per user per day | 18,396,507 | 2017-03-01 to 2017-03-31 |

### How the tables relate

All tables join on **`msno`**, the anonymised user ID. There are no declared primary or foreign keys in the raw layer.

```
                     raw.members  (1 row per user)
                          │ msno
       ┌──────────────────┼──────────────────────┐
       │                  │                      │
raw.train / train_v2   raw.transactions(_v2)   raw.user_logs(_v2)
(1 row per user,       (many rows per user,    (1 row per user per day,
 churn label)           payment events)         listening activity)
```

**Coverage differs between tables:**

- `members` lists 6.8 million users, but only some of them ever subscribed in the data period.
- `transactions` covers about 2.4 million distinct users, and `transactions_v2` about 1.2 million.
- 860,967 of the 970,960 users in `train_v2` (88.7%) appear in `members`. About 110,000 labelled users have **no member profile**.
- 881,701 users appear in **both** `train` and `train_v2`.

### Conventions

- **Dates are stored as `YYYYMMDD` integers** in the raw layer (for example `20170131`). They will be converted to `DATE` in `stg`.
- **Prices are in New Taiwan Dollars (NTD).**
- **ID codes are anonymised.** `city`, `registered_via` and `payment_method_id` are numeric codes without published labels; they can be used as categories but not interpreted by name.

---

## `raw.members`

Profile information for each user. Source: `members_v3.csv`.

| Field | Type | Description | Values in the data | Quality notes |
|-------|------|-------------|--------------------|---------------|
| `msno` | TEXT | Anonymised user ID | Unique per row (6,769,473 distinct) | No nulls, no duplicates |
| `city` | INTEGER | City code | 21 codes between 1 and 22; code `1` covers 71% of users | Code `1` may act as a default or unknown value; to be checked in EDA |
| `bd` | INTEGER | Age in years | −7,168 to 2,016 | **67.1% are `0`**; negative and implausible values exist. Treat values outside a plausible range (for example 10–80) as missing |
| `gender` | TEXT | Gender | `male` (1,195,355), `female` (1,144,613) | **65.4% missing** (4,429,505 rows) |
| `registered_via` | INTEGER | Registration channel code | 18 codes; `4`, `3`, `9` and `7` cover 99% of users | One row has `-1` |
| `registration_init_time` | INTEGER (YYYYMMDD) | Registration date | 2004-03-26 to 2017-04-29 | Some registrations fall in April 2017, after the transaction and listening data end |

---

## `raw.train` and `raw.train_v2`

Churn labels: the target variable. Source: `train.csv` and `train_v2.csv`.

| Field | Type | Description | Values in the data | Quality notes |
|-------|------|-------------|--------------------|---------------|
| `msno` | TEXT | Anonymised user ID | Unique per table | No nulls, no duplicates |
| `is_churn` | SMALLINT | `1` = churned, `0` = renewed | `train`: 63,471 churners (**6.39%**); `train_v2`: 87,330 churners (**8.99%**) | Strong class imbalance |

**Label definition** (from the organisers' code, `data/raw/WSDMChurnLabeller.scala`):

1. Take each user's transactions in the month before the label month and find their last membership expiry date. A cancellation moves the expiry date earlier.
2. Keep users whose membership expires in the label month (`train`: February 2017; `train_v2`: March 2017).
3. A user is labelled **churned** if they make **no new subscription transaction within 30 days** after that expiry date, and **not churned** if they do.

---

## `raw.transactions` and `raw.transactions_v2`

Payment, renewal and cancellation events. Source: `transactions.csv` and `transactions_v2.csv`. Both tables have the same columns.

| Field | Type | Description | Values in the data | Quality notes |
|-------|------|-------------|--------------------|---------------|
| `msno` | TEXT | Anonymised user ID | About 2.4 million distinct users | No nulls |
| `payment_method_id` | INTEGER | Payment method code | 40 codes between 1 and 41 | |
| `payment_plan_days` | INTEGER | Length of the plan bought, in days | 0 to 450; **30 days in 88%** of rows | `0` occurs in about 4% of rows; meaning unclear, to be checked in EDA |
| `plan_list_price` | INTEGER | List price of the plan (NTD) | 0 to 2,000; most common 149, 99, 0, 129, 180 | **6.95% are `0`** |
| `actual_amount_paid` | INTEGER | Amount actually paid (NTD) | 0 to 2,000 | **5.55% are `0`**; 3.98% of rows paid less than list price (discounts) |
| `is_auto_renew` | SMALLINT | `1` = auto-renewal on | 85.2% are `1` | |
| `transaction_date` | INTEGER (YYYYMMDD) | Date of the transaction | 2015-01-01 to 2017-02-28 | |
| `membership_expire_date` | INTEGER (YYYYMMDD) | Membership expiry date after this transaction | 1970-01-01 to 2017-03-31 | **1,778 rows before the year 2000** (placeholder dates such as `19700101`); 153,660 rows expire before their transaction date |
| `is_cancel` | SMALLINT | `1` = the user actively cancelled in this transaction | 4.0% are `1` | A cancellation can move the expiry date earlier. Must not be used as a churn feature from the outcome window (see [methodology.md](methodology.md)) |

**About `transactions_v2`:** it is not only March 2017. Of its 1,431,009 rows, 74.8% are from March 2017, 11.3% from January–February 2017 and 13.9% from before 2017. None of the pre-March rows exactly duplicate a row in `transactions`. How the two tables should be combined will be decided in EDA. Its expiry dates run from 2016-04-19 to 2036-10-15.

---

## `raw.user_logs` and `raw.user_logs_v2`

Daily listening activity. Source: `user_logs.csv` and `user_logs_v2.csv`. Both tables have the same columns.

> `raw.user_logs` has 392 million rows (43 GB). Statistics for it below come from a 0.5% random block sample (1,933,400 rows). `raw.user_logs_v2` was profiled in full.

| Field | Type | Description | Values in the data | Quality notes |
|-------|------|-------------|--------------------|---------------|
| `msno` | TEXT | Anonymised user ID | `user_logs_v2`: 1,103,894 distinct users | No duplicate user-days in `user_logs_v2` |
| `date` | INTEGER (YYYYMMDD) | Day of activity | `user_logs`: 2015-01-01 to 2017-02-28; `user_logs_v2`: March 2017 | |
| `num_25` | INTEGER | Songs played for **less than 25%** of their length | `user_logs_v2`: 0 to 5,639 | A high share suggests skipping |
| `num_50` | INTEGER | Songs played for 25–50% of their length | | |
| `num_75` | INTEGER | Songs played for 50–75% of their length | | |
| `num_985` | INTEGER | Songs played for 75–98.5% of their length | | |
| `num_100` | INTEGER | Songs played for **98.5–100%** of their length | `user_logs_v2`: up to 41,107 | A high share suggests engaged listening |
| `num_unq` | INTEGER | Unique songs played | Median 19 per active day; `user_logs_v2`: 1 to 4,925 | |
| `total_secs` | DOUBLE PRECISION | Total seconds played | Median 4,638 s (about 77 minutes) per active day | **Negative values** in `user_logs`, down to −9.2 × 10¹⁵ (311 rows in the sample). **Values above 86,400 s (24 hours)** in both tables (742 rows in the sample; 4,200 in `user_logs_v2`). Both are impossible and must be cleaned |

**Interpreting the `num_*` columns:** together they count every song play that day, split by how much of the song was heard. They are the main engagement signal: falling totals, fewer unique songs or a growing share of `num_25` plays may indicate a user drifting towards churn.

---

## Planned Derived Tables

To be documented as they are built:

- **`stg` schema:** typed and cleaned versions of the raw tables (real dates, invalid ages and placeholder dates set to null, impossible `total_secs` values handled).
- **`mart` schema:** analysis-ready tables, including a monthly listening summary per user and the customer-level feature table used for modelling.
- **Simulated experiment tables:** treatment assignment and outcomes for the simulated retention offer (see [simulation_assumptions.md](simulation_assumptions.md)).
