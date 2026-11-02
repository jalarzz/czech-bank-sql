# Czech Bank Analytics – Oracle SQL Project

An end-to-end SQL project on a real Czech bank dataset (the **Berka dataset**, 1993–1998). I loaded raw CSV files into Oracle Database, cleaned and translated the data into a proper relational model, and wrote analysis queries that answer business questions about clients, loans and regional wealth.

**Tools:** Oracle Database, SQL Developer, SQL (DDL, DML, aggregates, subqueries, CASE)
**Dataset:** [The Berka Dataset on Kaggle](https://www.kaggle.com/datasets/marceloventura/the-berka-dataset) (raw files not included in this repo)

---

## Dataset

8 semicolon-delimited files describing a Czech bank's clients and their activity:

| Table | Rows | Description |
|---|---|---|
| district | 77 | Demographics of each district (population, salary, unemployment, crime) |
| account | 4,500 | Bank accounts and their statement frequency |
| client | 5,369 | Clients with gender and birth date |
| disp | 5,369 | Links clients to accounts (owner or user) |
| order | 6,471 | Permanent payment orders |
| trans | 1,056,320 | Account transactions |
| loan | 682 | Loans with amount, duration and status |
| card | 892 | Credit cards issued |

---

## Project Structure

| File | What it does |
|---|---|
| `01_staging_tables.sql` | Creates raw text staging tables and checks row counts after import |
| `02_create_tables.sql` | Creates the clean tables with data types, keys and constraints |
| `03_transform_load.sql` | Converts, translates and loads staging data into the clean tables |
| `04_analysis_queries.sql` | Business analysis queries |

---

## Step 1 – Staging tables (`01_staging_tables.sql`)

- Set `NLS_NUMERIC_CHARACTERS = '.,'` so Oracle reads decimals with a dot correctly.
- Created 8 staging tables (`stg_*`) with every column as `VARCHAR2`, so the import wizard could load the raw files without type errors.
- Imported each CSV with SQL Developer's import wizard.
- Fixed a typo in a table name with `ALTER TABLE stf_disp RENAME TO stg_disp`.
- Validated the load with a `UNION ALL` row count across all staging tables, compared against the source files.

## Step 2 – Clean data model (`02_create_tables.sql`)

Designed 8 clean tables with proper types and integrity rules:

- **Primary keys** on every table.
- **Foreign keys** linking accounts and clients to districts, dispositions to clients and accounts, transactions, orders and loans to accounts, and cards to dispositions.
- **CHECK constraints**: gender `M/F`, disposition type `Owner/User`, transaction direction `Credit/Debit`, loan status `A–D`.
- **UNIQUE constraints**: one loan per account, one card per disposition.
- **NOT NULL** on required fields like dates and IDs.

```
district ──< account ──< disp >── client >── district
               │          │
               ├──< trans  └──< card
               ├──< perm_order
               └──< loan (1:1)
```

## Step 3 – Transform and load (`03_transform_load.sql`)

Moved data from staging into the clean tables with `INSERT INTO ... SELECT`, applying these transformations:

- **Type conversion:** `TO_NUMBER` for IDs and amounts.
- **Missing values:** `NULLIF(col, '?')` turned `?` placeholders in the district unemployment and crime columns into NULL.
- **Dates:** converted `YYMMDD` text into real dates with `TO_DATE('19' || date_raw, 'YYYYMMDD')`. For cards, only the first 6 characters of `'YYMMDD 00:00:00'` were used.
- **Gender and birth date from `birth_number`:** in this dataset, women's birth month has 50 added to it. I used `CASE` to derive gender (month > 50 = F) and `MOD(month, 50)` with `LPAD` to rebuild the real birth date.
- **Translating Czech codes into English** with `CASE`:
  - Statement frequency: `POPLATEK MESICNE` → Monthly, `POPLATEK TYDNE` → Weekly, `POPLATEK PO OBRATU` → After transaction
  - Transaction type: `PRIJEM` → Credit, `VYDAJ` / `VYBER` → Debit
  - Operations: `VYBER` → Cash withdrawal, `VKLAD` → Cash deposit, `VYBER KARTOU` → Card withdrawal, transfers to/from other banks
  - Purpose (`k_symbol`): `SIPO` → Household, `UVER` → Loan payment, `POJISTNE` → Insurance, `DUCHOD` → Pension, `UROK` → Interest, `SANKC. UROK` → Penalty interest, `SLUZBY` → Statement fee, `LEASING` → Leasing
  - Loan status: A → Finished, paid; B → Finished, not paid; C → Running, OK; D → Running, in debt
- **Cleaning:** `TRIM` on codes, blank purposes became NULL, and a partner account of `'0'` became NULL with `NULLIF`.

## Step 4 – Analysis (`04_analysis_queries.sql`)

| # | Business question | Why it matters | SQL used |
|---|---|---|---|
| 1 | Which districts and regions are the wealthiest? | Shows where the bank's higher-income markets are, for targeting products and branches | `ORDER BY` |
| 2 | What is the average loan amount? | A baseline for the bank's typical lending size | `AVG` |
| 3 | Which large loans (over 100,000) are not yet fully paid? | Highlights the biggest open credit exposure the bank should monitor | `WHERE`, `AND`, `!=`, `ORDER BY` |
| 4 | How many clients, accounts and loans does the bank have? | A quick big-picture view of the business | Scalar subqueries, `FROM dual` |
| 5 | What is the gender split of clients? | Basic customer profiling for marketing and product design | `GROUP BY`, `COUNT` |
| 6 | Are problem loans larger than healthy ones? | Helps the bank set loan limits and review large applications more carefully | `GROUP BY`, `MIN`, `MAX`, `AVG`, `ROUND` |

### Key findings

- The bank has **5,369 clients**, **4,500 accounts** and **682 loans**.
- Clients are almost evenly split: **2,724 men** and **2,645 women**.
- The average loan is about **151,410**, ranging from 4,980 to 590,820.
- **Problem loans are larger:** loans still running and in debt average about **249,285**, and finished-but-unpaid loans average about **140,721**, compared with about **91,641** for loans that were finished and fully paid. Larger loans carry more risk.

---

## What I learned

- Loading messy raw files safely through a staging layer
- Designing a relational schema with keys and constraints
- Cleaning and transforming data with `TO_DATE`, `TO_NUMBER`, `CASE`, `NULLIF`, `TRIM`, `SUBSTR`, `MOD` and `LPAD`
- Writing analysis queries with aggregates, `GROUP BY`, subqueries and filters, and explaining the business value of each

## Next steps

- More analysis with joins (accounts by region, loan risk by district)
- A Power BI dashboard built on top of this database
