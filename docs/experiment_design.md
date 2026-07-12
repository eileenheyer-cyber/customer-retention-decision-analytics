# Experiment Design: Retention Offer A/B Test

**Status: Planned / In Progress.** This document describes the *proposed design* of a randomized controlled experiment. The experiment has not yet been executed or simulated. Sample sizes, durations, and other numeric parameters below are placeholders to be calculated once baseline data assumptions are finalized — see the note at the end of this document.

> **Important limitation:** This experiment will be simulated using the synthetic NordHome dataset. It is designed to demonstrate correct experimental design and analysis methodology. It is **not** a real experiment and must not be interpreted as evidence of a real-world causal effect.

---

## Target Population

All active NordHome customers who are at risk of churn but still hold an active account at the start of the experiment window. The precise risk threshold (e.g., top N% by baseline churn score, or all customers above a minimum tenure) will be finalized during the data preparation phase.

---

## Eligibility Rules

Candidate eligibility criteria (to be finalized during implementation):

- Customer has an active subscription/account at the start of the experiment.
- Customer has a minimum tenure (e.g., at least one full billing cycle), to ensure sufficient historical data for feature engineering.
- Customer has not received a retention offer within a defined recent cooldown period, to avoid contamination from prior interventions.
- Customer is not already scheduled for cancellation at the time of assignment.

---

## Treatment Group

Receives the retention offer (e.g., a discount, credit, or service upgrade — exact mechanic to be defined during simulation design) shortly after assignment into the experiment.

## Control Group

Receives no retention offer and no additional contact beyond standard business-as-usual communication.

## Random Assignment

Customers meeting the eligibility criteria are randomly assigned to treatment or control, ideally using a stratified randomization scheme (e.g., stratified by baseline churn-risk tier) to improve balance between groups. Assignment is at the customer level, not the transaction level, since retention is a customer-level outcome.

---

## Primary Metric

**Retention rate** at the end of the observation period (i.e., the proportion of customers in each group who remain active), measured over a fixed outcome window following assignment.

## Secondary Metrics

- Time to churn (survival-style metric), among customers who do churn.
- Revenue or margin retained per customer.
- Engagement metrics (e.g., logins, purchases, support contacts) during the outcome window, as a check on behavioral response beyond the binary churn outcome.

## Guardrail Metrics

Metrics that should not be allowed to degrade as a side effect of the offer:

- Overall margin per customer (to catch cases where the incentive cost outweighs any retention gain).
- Customer complaints or negative support tickets (to catch a "sleeping dogs" effect where the offer irritates customers).
- Redemption/fulfillment cost overruns relative to plan.

---

## Hypotheses

- **Null hypothesis (H0):** The retention offer has no effect on retention rate; treatment and control groups have equal population retention rates.
- **Alternative hypothesis (H1):** The retention offer changes the retention rate; treatment and control group retention rates differ.

This is planned as a two-sided test at the average-effect level. Heterogeneous and individual-level effects are addressed separately through treatment-effect and uplift analysis (see [methodology.md](methodology.md)).

---

## Significance Level

Alpha (Type I error rate) is planned at **0.05**, a conventional standard for business experimentation, to be revisited if multiple secondary metrics require a multiple-comparisons adjustment.

## Statistical Power

Target power (1 − Type II error rate) is planned at **0.80**, another conventional standard, balancing the ability to detect a true effect against sample-size feasibility.

## Minimum Detectable Effect (MDE)

The MDE — the smallest true difference in retention rate the experiment is designed to reliably detect — will be defined based on business relevance (e.g., the smallest improvement in retention rate that would justify the incentive cost at scale). It has not yet been set numerically.

---

## Sample-Size Planning

**No specific sample size is defined in this document.** Required sample size per group depends on:

- The baseline (control-group) retention rate, which must be estimated from historical or simulated data.
- The chosen minimum detectable effect.
- The significance level (alpha) and statistical power selected above.

Once these inputs are defined during implementation, sample size will be calculated using a standard two-proportion power calculation (e.g., via `statsmodels` or `scipy`), and documented here before the experiment is simulated.

---

## Experiment Duration

The observation window must be long enough to capture a realistic churn decision cycle (e.g., at least one full billing/renewal cycle) while remaining short enough to be operationally feasible. The specific duration will be set once the churn definition and outcome window are finalized in [methodology.md](methodology.md).

---

## Possible Validity Threats

- **Interference/spillover:** Customers in treatment and control may interact (e.g., share offer details), diluting the measured effect. Assumed unlikely but should be documented as an assumption.
- **Novelty effects:** A short-term behavioral response to the offer that does not persist beyond the observation window.
- **Selection bias in eligibility:** If eligibility rules inadvertently correlate with the outcome, randomization within the eligible population still holds, but generalization to the full customer base may be limited.
- **Attrition/missing data:** Customers who cancel through channels not captured in the tracked outcome could bias measured retention rates.
- **Multiple comparisons:** Testing several secondary and guardrail metrics increases the risk of false positives; a pre-specified primary metric mitigates this for the main conclusion.

Because this experiment is simulated rather than observed, these threats are discussed for methodological completeness and to demonstrate awareness of experimental design risk — they do not represent issues actually detected in real data.

---

## Analysis Plan

1. Confirm randomization balance between treatment and control groups on pre-treatment covariates.
2. Test the primary metric (retention rate) using an appropriate two-proportion test (e.g., z-test for proportions or chi-square test).
3. Report the estimated average treatment effect with a confidence interval, not only a p-value.
4. Analyze secondary and guardrail metrics, applying multiple-comparison corrections where appropriate.
5. Proceed to heterogeneous treatment-effect and uplift analysis to move beyond the average effect (see [methodology.md](methodology.md)).