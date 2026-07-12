# Dashboard

**Status: Planned / In Progress.** No dashboard has been built yet.

## What Belongs Here

- Power BI (`.pbix`) files for the decision-support dashboard.
- Supporting assets used by the dashboard (e.g., exported summary tables, icons, or static images), once created.
- Brief documentation of the dashboard's intended views and how they map to the project's decision framework (e.g., a targeting-recommendation view, an experiment-results view).

## What Should Not Be Stored Here

- Power BI temporary/lock files (e.g., `~$*.pbix`, `.pbix.bak`) — these are excluded via `.gitignore`.
- Large raw data extracts feeding the dashboard — these belong in `data/` or should be connected to live from PostgreSQL rather than duplicated here.
- Credentials or data source connection strings.

## Naming Conventions

- Use a clear, versioned file name, e.g., `retention_decision_dashboard_v1.pbix`.
- Keep one primary dashboard file per major iteration rather than accumulating many similarly named copies.