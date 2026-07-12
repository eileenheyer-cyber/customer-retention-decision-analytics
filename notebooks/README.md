# Notebooks

**Status: Planned / In Progress.** No analysis notebooks have been created yet.

## What Belongs Here

- Jupyter notebooks used for exploratory data analysis, feature engineering exploration, model prototyping, experiment analysis, uplift modeling, and profit optimization.
- Notebooks should generally follow the project workflow order described in the main [README.md](../README.md) (e.g., EDA before modeling, modeling before uplift analysis).

## What Should Not Be Stored Here

- Production-ready or reusable logic that should live in versioned Python modules/scripts instead of only inside a notebook.
- Large data files or model artifacts — reference them from `data/` or `models/` instead of embedding them in the notebook directory.
- Notebook checkpoint files (`.ipynb_checkpoints/`) — these are excluded via `.gitignore` and should never be committed.
- Notebooks containing committed cell outputs with large data dumps; prefer clearing heavy outputs before committing where practical.

## Naming Conventions

- Prefix notebooks with a two-digit order number matching the project workflow, e.g., `01_eda.ipynb`, `02_churn_baseline_model.ipynb`, `03_ab_test_analysis.ipynb`, `04_uplift_modeling.ipynb`, `05_profit_optimization.ipynb`.
- Use lowercase, underscore-separated names describing the notebook's purpose, not its author or date.