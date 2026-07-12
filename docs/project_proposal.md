# Project Proposal: NordHome Retention Analytics

**Status: Planned / In Progress.** This document describes the intended scope and design of the project. No analysis has been performed yet.

---

## Executive Summary

NordHome Retention Analytics is a portfolio project designed to demonstrate an end-to-end, decision-oriented data science workflow applied to customer retention. Rather than stopping at a churn prediction model, the project extends into experimentation, treatment-effect estimation, uplift modeling, and expected-profit optimization, in order to answer a concrete business question: **which customers should receive a retention offer to maximize expected incremental profit?**

The project uses NordHome, a synthetic retail dataset, and a simulated randomized controlled experiment, to illustrate methods that would typically be applied to real customer and experiment data in an industry setting.

---

## Business Motivation

Retention campaigns are a common lever for reducing customer churn, but they carry a real cost — discounts, credits, or service upgrades all consume margin. A naive strategy of targeting every customer flagged as "high churn risk" ignores two important facts:

1. Many high-risk customers would remain regardless of any offer, or would leave regardless of any offer — the offer changes nothing for them.
2. Some customers may respond negatively to being contacted or incentivized, an effect a simple churn model cannot detect.

A more disciplined approach separates the *prediction* problem from the *intervention* problem, and makes the targeting decision using the economics of uplift, customer value, and cost — not risk alone.

---

## Project Scope

This project is scoped as an applied analytics case study. It includes:

- Business framing and problem definition.
- Design (not live execution) of a randomized controlled experiment for a retention offer.
- Simulation of experiment data consistent with that design.
- Data preparation and customer-level feature engineering.
- A baseline churn prediction model.
- Statistical analysis of the simulated A/B test.
- Heterogeneous treatment-effect and uplift modeling.
- An expected-profit targeting rule combining uplift, customer value, and incentive cost.
- A decision-support dashboard and a final business-facing report.

Out of scope: production deployment, real-time scoring infrastructure, integration with a live marketing system, and collection of real customer data.

---

## Key Research and Business Questions

- What is the baseline churn rate, and which customer attributes are most associated with churn?
- Does the retention offer, on average, produce a statistically significant improvement in retention?
- Does the effect of the offer vary meaningfully across customer segments?
- Which customers show a positive uplift in retention probability as a result of the offer?
- Given customer value and incentive cost, which customers should be targeted to maximize expected incremental profit?
- What are the risks of relying on churn prediction alone versus an uplift/profit-based approach?

---

## Analytical Components

1. **Churn prediction** — supervised classification to estimate churn probability.
2. **Experimental analysis (A/B testing)** — hypothesis testing to estimate the average treatment effect of the retention offer.
3. **Heterogeneous treatment-effect analysis** — examining whether the treatment effect varies across subgroups.
4. **Uplift modeling** — estimating individual-level treatment effects to identify customers whose behavior is changed by the offer.
5. **Expected-profit optimization** — combining uplift, customer value, and incentive cost into a targeting decision.
6. **Decision dashboard** — a business-facing summary of the targeting recommendation.

---

## Expected Outputs

- Written documentation of business problem, experiment design, and methodology (this repository's `docs/` folder).
- Cleaned, feature-engineered customer-level dataset (simulated).
- A trained and evaluated baseline churn model.
- A statistical analysis report of the simulated experiment.
- An uplift model with segment-level response estimates.
- A profit-optimized targeting list and sensitivity analysis.
- A Power BI dashboard.
- A final report with business recommendations.

---

## Risks and Limitations

- **Synthetic data:** NordHome is a synthetic dataset. Patterns in the data may not reflect real customer behavior.
- **Simulated experiment:** The randomized controlled experiment is simulated, not observed. It is intended to demonstrate correct experimental analysis methodology, not to provide evidence of a real causal effect.
- **Model generalization:** Any model trained on synthetic or simulated data should not be assumed to generalize to a real production environment without revalidation on real data.
- **Uplift modeling difficulty:** Uplift models are inherently harder to validate than standard predictive models because ground-truth individual treatment effects are never directly observable, even with real data.

These limitations are discussed further in [methodology.md](methodology.md) and reiterated in the final report once produced.

---

## Success Criteria

This project will be considered successful if it delivers:

- A clear, technically sound explanation of the difference between churn prediction, average treatment effect estimation, and uplift modeling.
- A correctly specified and documented experiment design.
- A baseline churn model evaluated using multiple appropriate metrics, not accuracy alone.
- A working uplift modeling approach with an honest discussion of its validation limitations.
- A profit-based targeting rule that is clearly connected to the underlying decision framework.
- Documentation and communication clear enough for a non-technical business stakeholder to follow the reasoning and conclusions.

This project does **not** claim to demonstrate a validated, production-ready retention strategy.

---

## Future Extensions

- Replace simulated experiment data with a real randomized experiment, if applied to a real business context.
- Extend uplift modeling to multiple treatment types (e.g., different offer sizes).
- Incorporate long-term customer lifetime value rather than a single-period value estimate.
- Explore causal inference methods for observational (non-randomized) retention data, where a controlled experiment is not feasible.
- Build a monitoring plan for drift in churn and uplift model performance over time.