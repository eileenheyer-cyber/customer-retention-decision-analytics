# Data

**Status: Planned / In Progress.** This project uses **synthetic data** for the fictional NordHome retail business. No real customer data is used or stored anywhere in this repository.

## What Belongs Here

- Documentation describing the synthetic dataset schema and data dictionary.
- Small sample or reference files (e.g., a few rows of example data) used to illustrate structure, if useful for portfolio presentation.
- Scripts or notes describing how the synthetic data and simulated experiment data were generated (once implemented).

## What Should Not Be Stored Here

- **Raw data files should not be committed if they are large or sensitive.** Even though NordHome data is synthetic, full datasets should be generated locally or stored externally (e.g., cloud storage, a local PostgreSQL instance) rather than committed to version control.
- Any real customer, transactional, or personally identifiable data. This project is intended to use synthetic data only.
- Database credentials or connection strings (see repository `.gitignore`).
- Large model training extracts or intermediate processing files — these belong in `models/` or should stay untracked locally.

## Naming Conventions

- Use lowercase, underscore-separated file names (e.g., `customers_raw.csv`, `experiment_assignment.csv`).
- Prefix generated/simulated files clearly (e.g., `simulated_` or `synthetic_`) to avoid any ambiguity about data provenance.
- Include a version or date suffix for any dataset snapshot that may be regenerated (e.g., `customers_2026_07.csv`).