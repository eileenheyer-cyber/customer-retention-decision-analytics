# Data

**Status: Raw data loaded.** This project uses the **KKBox Churn Prediction Challenge** dataset (WSDM Cup 2018), real anonymised subscription data from the music streaming service KKBox. This document explains where the data comes from and how to rebuild the local PostgreSQL database from scratch.

> **The data files are not in this repository.** KKBox data is Kaggle competition data and must not be redistributed. Everything in `data/raw/` and `data/processed/` is excluded by `.gitignore`. To reproduce the project, download the data with your own Kaggle account using the steps below.

---

## Dataset

**Source:** [KKBox's Churn Prediction Challenge](https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge) on Kaggle.

All tables link on `msno`, an anonymised user ID.

| File | Size | Rows | Contents |
|------|------|------|----------|
| `members_v3.csv` | 408 MB | 6,769,473 | One row per user: city, age (`bd`), gender, registration channel and date |
| `train.csv` | 45 MB | 992,931 | Churn labels for subscriptions expiring in February 2017 |
| `train_v2.csv` | 44 MB | 970,960 | Churn labels for subscriptions expiring in March 2017 |
| `transactions.csv` | 1.6 GB | 21,547,746 | Payment, renewal and cancellation events, January 2015 to February 2017 |
| `transactions_v2.csv` | 110 MB | 1,431,009 | Transactions mostly from March 2017 (75%), plus earlier dates back to 2015 |
| `user_logs.csv` | 28 GB | 392,106,543 | Daily listening activity per user, 2015 to February 2017 |
| `user_logs_v2.csv` | 1.3 GB | 18,396,507 | Daily listening activity for March 2017 |
| `WSDMChurnLabeller.scala` | 7 KB | — | The organisers' code that defines the churn label |

**Churn definition** (from `WSDMChurnLabeller.scala`): a user whose membership expires in the label month is a churner if they make no new subscription transaction within **30 days** of the expiry date.

---

## Pipeline Overview

```
Kaggle  ──(kaggle CLI)──▶  data/raw/*.csv  ──(psql \copy)──▶  PostgreSQL: kkbox_retention
                                                              ├── raw   files loaded as-is
                                                              ├── stg   cleaned and typed (planned)
                                                              └── mart  analysis-ready tables (planned)
```

| Step | File | What it does |
|------|------|--------------|
| 1 | [`scripts/download_data.sh`](../scripts/download_data.sh) | Downloads and extracts the CSVs into `data/raw/` |
| 2 | One-time setup (below) | Creates the database, login and schemas |
| 3 | [`sql/01_create_raw_tables.sql`](../sql/01_create_raw_tables.sql) | Creates the 7 empty tables in `raw` |
| 4 | [`sql/02_load_raw_data.sql`](../sql/02_load_raw_data.sql) | Loads each CSV into its table |

---

## Step 1: Download the Data

### Prerequisites

1. **Kaggle API token.** On Kaggle, go to **Settings → API Tokens → Generate New Token**. Save it in your shell profile (`~/.zshrc` on macOS) so it is available in every terminal, and keep it out of the repository:
   ```bash
   echo 'export KAGGLE_API_TOKEN=your_token' >> ~/.zshrc
   source ~/.zshrc
   ```
2. **Accept the competition rules** on the competition's **Data** tab. Downloads fail with error 403 until you do.
3. **Install the tools:**
   ```bash
   pip install "kaggle>=1.8.0" py7zr
   ```
   - `kaggle` is Kaggle's command-line tool. Version 1.8.0 or newer is needed for the new API tokens.
   - `py7zr` extracts the `.7z` archives the data is distributed in.
4. **Check that it works:**
   ```bash
   kaggle competitions files -c kkbox-churn-prediction-challenge
   ```

### Download

From the repository root:

```bash
bash scripts/download_data.sh
```

The script downloads each archive (about 9 GB compressed), extracts it into `data/raw/` and deletes the archive. Small files come first and the 7.1 GB `user_logs` archive last. Files that already exist are skipped, so the script is safe to re-run. Extracted, the data takes about **32 GB**.

---

## Step 2: One-Time PostgreSQL Setup

These steps need the `postgres` superuser, so run them in pgAdmin's Query Tool on the **PostgreSQL 18** connection.

1. **Create the database.** Right-click **Databases → Create → Database…**, or connected to the `postgres` database:
   ```sql
   CREATE DATABASE kkbox_retention;
   ```
2. **Create a project login and the schemas.** Connected to `kkbox_retention`:
   ```sql
   CREATE ROLE kkbox_loader LOGIN PASSWORD 'choose_a_password';

   CREATE SCHEMA raw  AUTHORIZATION kkbox_loader;
   CREATE SCHEMA stg  AUTHORIZATION kkbox_loader;
   CREATE SCHEMA mart AUTHORIZATION kkbox_loader;
   ```
   `kkbox_loader` owns the three schemas, so it can create and fill tables there, but it has no access to other databases. Day-to-day work uses this login instead of the all-powerful `postgres` account.
3. **Save the password locally** so command-line tools log in without prompting. The file lives in your home folder, outside the repository:
   ```bash
   echo 'localhost:5432:kkbox_retention:kkbox_loader:choose_a_password' >> ~/.pgpass
   chmod 600 ~/.pgpass
   ```
   PostgreSQL ignores `.pgpass` unless only you can read it, which is what `chmod 600` ensures.
4. **Optional: add a pgAdmin connection** for `kkbox_loader`. Right-click **Servers → Register → Server…**, enter a name on the **General** tab, and on the **Connection** tab use host `localhost`, port `5432`, database `kkbox_retention`, username `kkbox_loader` and its password.

**Database structure:**

```
PostgreSQL server (localhost:5432)
└── Database: kkbox_retention
    ├── Schema: raw   → members, train, train_v2, transactions, transactions_v2, user_logs, user_logs_v2
    ├── Schema: stg   → cleaned tables (planned)
    └── Schema: mart  → analysis-ready tables (planned)
```

---

## Step 3–4: Create and Load the Raw Tables

Run from the **repository root**, because the load script uses paths relative to it. On macOS with the EDB installer, `psql` is in `/Library/PostgreSQL/18/bin/`.

```bash
psql -h localhost -U kkbox_loader -d kkbox_retention -f sql/01_create_raw_tables.sql
psql -h localhost -U kkbox_loader -d kkbox_retention -f sql/02_load_raw_data.sql
```

### What the scripts do

**`01_create_raw_tables.sql`** creates one table per CSV in the `raw` schema. The columns match each file's header **in the same order**, and dates stay as `YYYYMMDD` integers. The raw layer is deliberately permissive: converting dates or rejecting bad values here could make the whole load fail on a single bad row. Cleaning happens later in `stg`.

**`02_load_raw_data.sql`** loads each file with two commands, for example:

```sql
TRUNCATE raw.transactions_v2;
\copy raw.transactions_v2 FROM 'data/raw/transactions_v2.csv' WITH (FORMAT csv, HEADER true)
```

- `TRUNCATE` empties the table first, so re-running the script never duplicates data.
- `\copy` reads the CSV and inserts every line as a row:
  - `FORMAT csv` means the values are comma-separated.
  - `HEADER true` skips the first line, which holds column names.
  - Columns are matched **by position**, which is why the table column order must match the file.
- `\copy` is a **psql** command, not SQL. It ends at the end of the line, with no semicolon, and it does not run in pgAdmin's Query Tool.

**Why `\copy` and not `COPY`:** both do the same thing, but `COPY` makes the PostgreSQL *server* open the file. The server runs as a separate system user that cannot read your home folder. `\copy` makes psql, running as you, read the file and stream the rows to the server.

The files are **copied, not moved**. PostgreSQL stores its own copy in its data directory (`/Library/PostgreSQL/18/data/`), so the CSVs could be deleted afterwards and re-downloaded if needed.

**Load times on the author's machine** (Intel i7, 16 GB RAM):

| Table | Time |
|-------|------|
| members | 17 s |
| transactions | 48 s |
| user_logs_v2 | 1 min 40 s |
| user_logs | Most of the total; the 28 GB file dominates |

The database takes about **48 GB** after loading, of which `user_logs` is 43 GB.

---

## Verify the Load

Run in pgAdmin's Query Tool on `kkbox_retention`:

```sql
SELECT
    relname                                        AS table_name,
    n_live_tup                                     AS approx_rows,
    pg_size_pretty(pg_total_relation_size(relid))  AS size
FROM pg_stat_user_tables
WHERE schemaname = 'raw'
ORDER BY pg_total_relation_size(relid) DESC;
```

`n_live_tup` is PostgreSQL's row estimate. It is instant, and it can differ slightly from the exact counts in the dataset table above. Use `SELECT COUNT(*) FROM raw.members;` for an exact count, but avoid it on `raw.user_logs`, where it scans 392 million rows.

---

## Working With the Data

- **`raw.user_logs` is too large for pandas.** At 392 million rows it would need roughly 30–40 GB of RAM. Always aggregate it in PostgreSQL first, for example to one row per user per month.
- **The other tables can be loaded into pandas directly.** For the larger ones (`transactions`, `user_logs_v2`), load only the columns you need and store `msno` as a `category`.

---

## Known Data Quality Issues

Found during loading; to be investigated in `eda/02_data_quality.ipynb`:

- `members.bd` (age): only about 33% of values fall between 1 and 90; the rest are 0, negative or implausible.
- `members.gender`: about 65% missing.
- `transactions.membership_expire_date` contains placeholder dates such as `19700101`.
- Table coverage differs: `members` has 6.8 million users, `transactions` covers about 2.4 million distinct users, and each label file has about 1 million. How these overlap still needs checking.

---

## Troubleshooting

Problems encountered (or anticipated) while building this pipeline, and their fixes:

| Problem | Cause | Fix |
|---------|-------|-----|
| `kaggle` fails with error 403 | Competition rules not accepted | Accept them on the competition's **Data** tab |
| Kaggle token not recognised | Old CLI version, or legacy `kaggle.json` expected | Use `kaggle>=1.8.0` with `KAGGLE_API_TOKEN` |
| CSVs not found after extraction | Archives contain nested folders (`data/churn_comp_refresh/...`) | The download script moves each CSV up into `data/raw/` |
| `database "kkbox_retention" does not exist` although it is listed in pgAdmin | The name was created with a leading space; pgAdmin does not show it | `ALTER DATABASE " kkbox_retention" RENAME TO kkbox_retention;` run from the `postgres` database with no open connections to it |
| `permission denied for database` on `CREATE SCHEMA IF NOT EXISTS` | Creating schemas needs database-level rights, even if they exist | Create schemas once as `postgres` (Step 2); the table script does not create them |
| `COPY` cannot read the CSV | The server process has no access to your home folder | Use psql's `\copy` |
| A pgAdmin Query Tool tab keeps asking for a password after a rename | The tab still points to the old database name and login | Close the tab, refresh **Databases**, and open a new Query Tool |
| `permission denied to analyze "pg_..."` warnings | A bare `ANALYZE` also tries system tables | Harmless; the script now analyses only the `raw` tables |
