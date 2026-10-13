# Customer Retention Decision Analytics: From Churn Prediction to Profit-Optimal Targeting

**Combining machine learning, experimentation, uplift modeling and business decision analytics to optimize customer retention.**

---

## Project Inspiration

This project was inspired by concepts presented in *Data Science for Business* by Foster Provost and Tom Fawcett. In particular, the discussions on expected value, customer retention, and decision-focused analytics motivated the overall project design. While the implementation is my own, the project explores how these ideas can be applied to real subscription data.

---

## Project Status

**In Progress.** The KKBox dataset has been downloaded and loaded into PostgreSQL (see [data/README.md](data/README.md)). No data analysis, modeling, or dashboard code has been implemented yet. See [docs/roadmap.md](docs/roadmap.md) for the current phase and progress checklist.

---

## Business Context

This project uses the **KKBox Churn Prediction Challenge** dataset (WSDM Cup 2018): real, anonymised data from KKBox, a music streaming subscription service in Taiwan. It covers about one million labelled subscribers, with member profiles, more than 21 million payment and renewal transactions, and 392 million daily listening logs from 2015 to 2017.

Like every subscription business, KKBox loses part of its subscriber base each month: 6–9% of users whose subscription expired in early 2017 did not renew within 30 days. A common first response is to build a churn prediction model and offer a retention incentive (discount, loyalty credit, or service upgrade) to every customer flagged as high-risk.

This project argues — and aims to demonstrate — that this common approach is incomplete. Knowing *who is likely to churn* is not the same as knowing *who will respond profitably to an intervention*. This project builds the analytical workflow needed to close that gap.

---

## Main Business Question

> **Which customers should receive a retention offer to maximize expected incremental profit?**

This question is deliberately different from "which customers are likely to churn?" It requires reasoning about prediction, causal effect, and economics together, not prediction alone.

---

## Why Churn Prediction Alone Is Insufficient

A churn model estimates the probability that a customer will leave. It does **not** estimate whether a retention offer will change that outcome, and it says nothing about whether spending the incentive is profitable for a given customer. Targeting purely on churn risk typically wastes budget on customers who would have stayed anyway, and can even be counterproductive for customers who react negatively to being contacted.

This project distinguishes four related but distinct analytical questions, detailed further in [docs/business_problem.md](docs/business_problem.md):

1. **Churn prediction** — Who is likely to leave?
2. **A/B testing** — Does the retention offer work on average?
3. **Uplift modeling** — For which customers does the offer change behavior?
4. **Expected-value optimization** — Which customers should be targeted profitably?

---

## Project Objectives

- Build a baseline churn prediction model on customer-level features.
- Design and simulate a randomized controlled experiment (A/B test) for a retention offer.
- Estimate the average and heterogeneous treatment effects of the offer.
- Build an uplift model to identify customers whose behavior is actually changed by the offer.
- Combine uplift estimates, customer value, and incentive cost into an expected-profit targeting rule.
- Communicate findings through a decision-support dashboard and a set of business recommendations.
- Be explicit and honest about the methodological limitations of using simulated experimental data.

---

## Decision Framework

The targeting decision is guided by the following formula:

```
Expected Incremental Profit
  = Estimated uplift in retention probability
    × Estimated customer value
    − Incentive cost
```

A customer should only be targeted with a retention offer when this expected value is positive. This framework is what separates this project from a standard churn-prediction exercise: it converts a prediction into an economic decision.

---

## Planned Workflow

1. Business understanding
2. Data preparation
3. Customer-level feature engineering
4. Exploratory data analysis
5. Churn definition
6. Baseline churn prediction
7. Experiment design
8. A/B test analysis
9. Heterogeneous treatment-effect analysis
10. Uplift modeling
11. Expected-profit optimization
12. Decision dashboard
13. Business recommendations
14. Limitations and future work

Full methodological detail is available in [docs/methodology.md](docs/methodology.md), and the phased task breakdown is in [docs/roadmap.md](docs/roadmap.md).

---

## Repository Structure

```
customer-retention-decision-analytics/
├── README.md                     # Project overview (this file)
├── docs/
│   ├── project_proposal.md       # Formal project proposal
│   ├── business_problem.md       # Business framing: targeting segments and decision logic
│   ├── experiment_design.md      # Proposed A/B test design
│   ├── methodology.md            # Planned analytical and statistical methods
│   ├── data_dictionary.md        # Table and field definitions
│   ├── simulation_assumptions.md # Assumptions for the simulated retention offer
│   └── roadmap.md                # Phased task checklist and progress tracking
├── data/                         # Data documentation and setup guide (data files not committed)
│   ├── raw/                      # Downloaded KKBox CSVs
│   ├── processed/                # Intermediate outputs
│   └── synthetic/                # Simulated experiment data
├── scripts/                      # Data download script
├── sql/                          # SQL scripts for loading, cleaning and feature building
├── eda/                          # Exploratory data analysis notebooks
├── notebooks/                    # Analysis notebooks (churn, experiment, uplift, profit)
├── models/                       # Trained model artifacts and evaluation outputs
├── dashboard/                    # Power BI dashboard files and assets
├── reports/                      # Final written reports and summaries
└── .gitignore
```

Each folder contains its own `README.md` describing its intended contents and conventions.

---

## Planned Technology Stack

- **PostgreSQL** — data storage
- **SQL** — data extraction and transformation
- **Python** — analysis and modeling
- **Pandas / NumPy** — data manipulation
- **Matplotlib** — visualization
- **Scikit-learn** — baseline modeling and evaluation
- **SciPy / statsmodels** — statistical testing and inference
- **XGBoost** — gradient-boosted tree model, if justified by baseline results
- **SHAP** — model interpretability, if justified by the modeling approach chosen
- **Power BI** — decision dashboard
- **Git and GitHub** — version control and project documentation

---

## Expected Deliverables

- A documented, reproducible data preparation and feature engineering pipeline.
- A baseline churn prediction model with a transparent evaluation report.
- A simulated randomized experiment with a complete analysis write-up.
- An uplift model identifying customer response segments.
- A profit-optimized targeting recommendation, with sensitivity analysis.
- A Power BI dashboard summarizing the targeting decision for a business audience.
- A final report translating analytical findings into business recommendations.

---

## Important Methodological Limitation

The customer, transaction, listening and churn data are **real** (KKBox, anonymised). KKBox never ran a retention-offer experiment in this data, however, so the randomized controlled experiment in this project will be **simulated on top of the real subscribers**: treatment assignment and the offer's effect are generated under documented assumptions (see [docs/simulation_assumptions.md](docs/simulation_assumptions.md)). The simulation is intended solely to demonstrate the analytical workflow — experiment design, statistical testing, treatment-effect estimation, and uplift modeling.

The churn prediction results reflect real subscriber behaviour. **Results from the simulated experiment must not be interpreted as evidence of real-world causal impact.** They illustrate methodology, not a validated business outcome. Any real-world application of this workflow would require a genuine randomized experiment on actual customers.

---

## Progress Checklist

- [x] Define business problem and project scope
- [x] Set up repository structure and documentation
- [x] Source dataset (KKBox) and load it into PostgreSQL
- [ ] Simulate the retention experiment
- [ ] Data preparation and feature engineering
- [ ] Exploratory data analysis and churn definition
- [ ] Baseline churn prediction model
- [ ] A/B test analysis
- [ ] Heterogeneous treatment-effect analysis
- [ ] Uplift modeling
- [ ] Expected-profit optimization
- [ ] Decision dashboard
- [ ] Final report and business recommendations

See [docs/roadmap.md](docs/roadmap.md) for the detailed phase-by-phase breakdown.

---

## Author Learning Goals

This project is being built as a portfolio piece to demonstrate applied, decision-oriented data science skills, specifically:

- Moving beyond predictive modeling toward causal and economic reasoning.
- Designing and analyzing randomized experiments correctly.
- Understanding and applying uplift modeling as distinct from standard classification.
- Translating statistical results into a business-usable targeting policy.
- Communicating technical analysis clearly to a non-technical, business-facing audience.