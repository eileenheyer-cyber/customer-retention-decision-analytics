# Project Roadmap

**Status: Planned / In Progress.** This roadmap tracks progress across project phases. Only the items explicitly checked below have been completed; everything else is planned work.

---

## Phase 1: Project Definition

- [x] Define the central business question
- [x] Document the business problem and targeting logic (sure things, persuadables, lost causes, sleeping dogs)
- [x] Write the project proposal
- [x] Set up repository structure and folder-level documentation
- [x] Define planned technology stack

## Phase 2: Dataset and Experiment Simulation

- [ ] Define the synthetic NordHome customer dataset schema
- [ ] Generate synthetic customer-level data
- [ ] Define the retention offer mechanic to be simulated
- [ ] Simulate randomized treatment/control assignment
- [ ] Simulate post-treatment outcomes consistent with the experiment design

## Phase 3: Data Preparation

- [ ] Load simulated data into PostgreSQL
- [ ] Write SQL extraction/transformation scripts
- [ ] Define observation, prediction, and outcome windows
- [ ] Clean and validate data quality
- [ ] Document data dictionary

## Phase 4: EDA and Churn Definition

- [ ] Explore customer distributions and segment characteristics
- [ ] Finalize the operational churn definition
- [ ] Analyze class balance and baseline churn rate
- [ ] Document key EDA findings

## Phase 5: Churn Modeling

- [ ] Engineer customer-level features (leakage-checked)
- [ ] Build train/validation/test splits
- [ ] Train baseline logistic regression model
- [ ] Train and compare tree-based model(s), if justified
- [ ] Evaluate models using ROC-AUC, PR-AUC, recall, precision, F1, log loss, and calibration
- [ ] Select and document final churn model

## Phase 6: Experiment Analysis

- [ ] Confirm randomization balance in simulated experiment data
- [ ] Test primary metric (retention rate) and report effect size with confidence interval
- [ ] Analyze secondary and guardrail metrics
- [ ] Document A/B test conclusions

## Phase 7: Uplift Modeling

- [ ] Analyze heterogeneous treatment effects across segments
- [ ] Build uplift model (two-model or class-transformation approach)
- [ ] Validate uplift model using appropriate uplift-specific metrics (e.g., Qini curve)
- [ ] Document uplift modeling findings and limitations

## Phase 8: Profit Optimization

- [ ] Define customer value estimation approach
- [ ] Define incentive cost assumptions
- [ ] Calculate expected incremental profit per customer
- [ ] Propose profit-based targeting threshold
- [ ] Run sensitivity analysis on value and cost assumptions

## Phase 9: Dashboard

- [ ] Design dashboard layout and key views
- [ ] Build Power BI data model
- [ ] Build targeting decision dashboard
- [ ] Review dashboard for business clarity and usability

## Phase 10: Documentation and Final Review

- [ ] Write final report and business recommendations
- [ ] Review all documentation for consistency and accuracy
- [ ] Reconfirm and restate methodological limitations
- [ ] Final repository cleanup and polish