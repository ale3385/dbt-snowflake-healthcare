# Healthcare Claims Analytics — dbt + Snowflake

A production-grade dbt project for healthcare claims data modeling on Snowflake. Demonstrates dimensional modeling, incremental processing, data quality testing, and CI/CD for analytics engineering.

## Architecture

```
         S3 / SFTP / API
              │
              ▼
    ┌───────────────────┐
    │   RAW (Sources)   │  COPY INTO from S3, Snowpipe
    │                   │  patients, providers, claims,
    │                   │  claim_lines, diagnoses
    └────────┬──────────┘
             │
             ▼
    ┌───────────────────┐
    │  STAGING (Views)  │  Cleaning, typing, renaming
    │                   │  stg_patients, stg_providers,
    │                   │  stg_claims, stg_claim_lines,
    │                   │  stg_diagnoses
    └────────┬──────────┘
             │
             ▼
    ┌───────────────────┐
    │  MARTS (Tables)   │  Dimensional models
    │                   │
    │  core/            │  dim_patients, dim_providers,
    │                   │  dim_diagnoses, fct_claims
    │                   │
    │  finance/         │  rpt_monthly_claims_summary,
    │                   │  rpt_provider_performance
    └───────────────────┘
```

## Project Structure

```
├── models/
│   ├── sources.yml              # Source definitions with freshness checks
│   ├── staging/                 # Cleaning & standardization (views)
│   │   ├── stg_patients.sql
│   │   ├── stg_providers.sql
│   │   ├── stg_claims.sql
│   │   ├── stg_claim_lines.sql
│   │   ├── stg_diagnoses.sql
│   │   └── _staging.yml         # Tests & documentation
│   └── marts/
│       ├── core/                # Dimensional models (tables)
│       │   ├── dim_patients.sql
│       │   ├── dim_providers.sql
│       │   ├── dim_diagnoses.sql
│       │   ├── fct_claims.sql   # Incremental merge
│       │   └── _core.yml
│       └── finance/             # Reporting layer
│           ├── rpt_monthly_claims_summary.sql
│           ├── rpt_provider_performance.sql
│           └── _finance.yml
├── macros/
│   ├── cents_to_dollars.sql     # Currency conversion helper
│   ├── generate_schema_name.sql # Env-aware schema routing
│   └── limit_in_dev.sql         # Dev performance optimization
├── seeds/
│   └── diagnosis_codes.csv      # ICD-10 reference data
├── snapshots/
│   └── snap_patients.sql        # SCD Type 2 patient tracking
├── tests/
│   ├── assert_claim_paid_not_exceeds_billed.sql
│   └── assert_no_future_service_dates.sql
└── .github/workflows/ci.yml    # sqlfluff lint + dbt compile
```

## Key Patterns

### Layered Modeling
- **Sources** — Raw data with freshness monitoring (warn at 24h, error at 48h)
- **Staging** — Materialized as views. Handles cleaning, type casting, null filtering, and standardization
- **Marts** — Materialized as tables. Dimensional models (dims/facts) and report-ready aggregations

### Incremental Processing
`fct_claims` uses Snowflake's `MERGE` strategy to incrementally process only new/updated records based on `_loaded_at`, avoiding full table scans on large claim volumes.

### Data Quality
- **Schema tests**: unique, not_null, accepted_values, relationships across all layers
- **dbt_expectations**: range validation (age 0-120, payment rate 0-200%)
- **Singular tests**: business rules (paid vs billed thresholds, no future service dates)
- **Source freshness**: automated staleness detection

### SCD Type 2
`snap_patients` tracks changes in insurance plan, location, and enrollment status over time using dbt's `check` strategy.

### Environment Handling
- `generate_schema_name` macro routes schemas per environment (dev uses prefixed schemas, prod uses clean names)
- `limit_in_dev` macro restricts data volume during development
- Database configurable via `SNOWFLAKE_DATABASE` env var

## Setup

```bash
# Clone
git clone https://github.com/ale3385/dbt-snowflake-healthcare.git
cd dbt-snowflake-healthcare

# Install
pip install dbt-snowflake

# Configure (copy and edit with your Snowflake credentials)
cp profiles/profiles.yml.example ~/.dbt/profiles.yml

# Install packages
dbt deps

# Seed reference data
dbt seed

# Run snapshots
dbt snapshot

# Build all models
dbt run

# Test
dbt test

# Generate docs
dbt docs generate && dbt docs serve
```

## CI/CD

Pull requests trigger automated checks via GitHub Actions:
1. **sqlfluff lint** — SQL style enforcement (Snowflake dialect)
2. **dbt compile** — Validates all models compile without errors

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Warehouse | Snowflake |
| Transformation | dbt-core |
| SQL Linting | sqlfluff |
| CI/CD | GitHub Actions |
| Language | SQL, Jinja |

## License

MIT
