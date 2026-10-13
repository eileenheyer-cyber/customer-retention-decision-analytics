# Methodology

**Status: Planned / In Progress.** This document describes the analytical methods this project intends to use. No models have been trained and no results are reported yet.

---

## Observation Window, Prediction Window, and Outcome Window

To avoid ambiguity and data leakage, the project will define three distinct time windows before any feature engineering or modeling begins:

- **Observation window:** The historical period from which customer features are calculated (e.g., past purchase behavior, engagement, tenure).
- **Prediction window:** The point in time at which a prediction or targeting decision is made ("as of" date).
- **Outcome window:** The forward-looking period over which the churn outcome (and, in the experiment, the treatment effect) is measured.

All three windows will be explicitly documented once defined, and features will only ever be built from data available strictly before the prediction point.

---

## Churn Definition

Churn follows the KKBox competition definition (`data/raw/WSDMChurnLabeller.scala`): a subscriber whose membership expires in the label month churns if they make no new subscription transaction within 30 days of the expiry date. The definition and its implications for the outcome window will be examined and documented in the EDA phase.

---

## Leakage Prevention

- No feature may be calculated using data from the outcome window.
- Any feature derived from an event that could only be known *because* the customer churned (e.g., a cancellation reason code) will be excluded from churn prediction features.
- Train/validation/test splits will respect time order where feasible, to avoid look-ahead bias.
- The experiment's treatment assignment and outcome data will be kept strictly separate from the churn model's training data to avoid contaminating one analysis with the other.

---

## Feature Engineering

Planned customer-level features include (subject to what the KKBox data supports):

- Tenure and account age.
- Recency, frequency, and monetary (RFM)-style purchase or usage behavior.
- Engagement trends (e.g., change in activity over recent periods).
- Support/complaint history.
- Product or plan attributes.

Feature engineering will be performed strictly from the observation window, as described above.

---

## Train / Validation / Test Strategy

A standard three-way split (train / validation / test) is planned for the churn prediction model, with the test set held out until final evaluation. Where relevant, splits will be stratified by churn outcome to preserve class balance across sets. Cross-validation will be used during model selection on the training data.

---

## Baseline Model: Logistic Regression

A logistic regression model is planned as the interpretable baseline. It provides a transparent reference point for evaluating whether more complex models are justified, and its coefficients offer directly interpretable relationships between features and churn risk.

## Tree-Based Models

If the baseline logistic regression underperforms or fails to capture non-linear relationships, tree-based models (e.g., **XGBoost**) will be evaluated. The decision to use a more complex model will be justified by measurable improvement over the baseline, not adopted by default.

---

## Model Evaluation

Because churn is typically an imbalanced outcome, model selection will **not** be based on accuracy alone. Planned evaluation metrics include:

- **ROC-AUC** — overall ranking ability across thresholds.
- **PR-AUC** — more informative than ROC-AUC under class imbalance.
- **Recall** — proportion of actual churners correctly identified.
- **Precision** — proportion of predicted churners who actually churn.
- **F1 score** — harmonic balance of precision and recall.
- **Log loss** — penalizes poorly calibrated probability estimates.
- **Calibration curve** — visual check of whether predicted probabilities match observed churn rates.

The relative importance of these metrics will depend on the business use case (e.g., recall may be prioritized if the cost of missing a churner is high), and this trade-off will be documented explicitly rather than left implicit.

---

## Probability Calibration

Because the churn model's output probabilities feed directly into the expected-profit formula, calibration matters as much as ranking ability. If the baseline model's probabilities are poorly calibrated, calibration techniques (e.g., Platt scaling or isotonic regression) will be considered before using those probabilities in downstream profit calculations.

---

## A/B Test Analysis

As described in [experiment_design.md](experiment_design.md), the simulated experiment will be analyzed using a two-proportion hypothesis test for the primary metric, reporting both statistical significance and a confidence interval for the estimated average treatment effect.

---

## Treatment-Effect Estimation

Beyond the average treatment effect, the project will examine **heterogeneous treatment effects** — whether the effect of the offer differs across customer subgroups (e.g., by tenure, risk tier, or value segment). This is an intermediate step between "does the offer work on average?" and the more granular uplift modeling step below.

---

## Uplift Modeling

Uplift modeling will be used to estimate individual-level (or segment-level) treatment effects — i.e., the incremental change in retention probability caused by the offer for each customer, rather than their absolute churn probability. Candidate approaches include:

- **Two-model approach** — separate models for treatment and control groups, with uplift estimated as the difference in predicted outcomes.
- **Class transformation methods** — reframing uplift estimation as a single classification problem.
- Dedicated uplift-tree or uplift-forest methods, if a suitable library is adopted.

The choice of method will be documented along with its trade-offs, since uplift models are fundamentally harder to validate than standard classifiers (individual treatment effects are never directly observed, even in real data — only average effects within groups can be validated).

---

## Profit-Based Targeting

The core decision rule combines uplift, customer value, and incentive cost:

```
Expected Incremental Profit
  = Estimated uplift in retention probability
    × Estimated customer value
    − Incentive cost
```

Customers will be ranked by expected incremental profit, and a targeting threshold (target only customers with positive expected profit) will be proposed. This converts the uplift model's output into an actionable business decision, consistent with the project's central question.

---

## Sensitivity Analysis

Because customer value and incentive cost are estimates, not certainties, the project will test how the targeting recommendation changes under different assumptions (e.g., ±20% variation in customer value or incentive cost). This is intended to show how robust — or fragile — the recommended targeting policy is, rather than presenting a single point estimate as definitive.