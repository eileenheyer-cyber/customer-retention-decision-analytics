# Models

**Status: Planned / In Progress.** No models have been trained yet.

## What Belongs Here

- Serialized/trained model artifacts (e.g., the baseline logistic regression model, tree-based churn model, and uplift model), once trained.
- Model evaluation summaries and metric reports (e.g., ROC-AUC, PR-AUC, calibration results) associated with a specific trained model version.
- Configuration files documenting model hyperparameters used for a given trained artifact.

## What Should Not Be Stored Here

- **Large model artifacts should not be committed directly to version control** unless they are small enough to be reasonably versioned (see repository `.gitignore`). Larger artifacts should be stored externally or regenerated from the training notebooks/scripts.
- Raw or intermediate training data — that belongs in `data/`.
- Any credentials or environment configuration.

## Naming Conventions

- Include the model type and version/date in the file name, e.g., `churn_logreg_baseline_v1.pkl`, `churn_xgboost_v1.pkl`, `uplift_two_model_v1.pkl`.
- Pair each model artifact with a corresponding evaluation summary using a matching name, e.g., `churn_xgboost_v1_metrics.json`.