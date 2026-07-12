# Business Problem

**Status: Planned / In Progress.** This document defines the business framing that motivates the rest of the project. It does not yet contain analysis results.

---

## Why Targeting Every High-Risk Customer Is Inefficient

A common but flawed retention strategy is: "rank customers by churn probability, offer an incentive to everyone above a threshold." This ignores the fact that churn probability alone says nothing about how a customer would respond to an intervention. It conflates two very different quantities:

- **P(churn)** — the probability a customer leaves under current conditions.
- **Treatment effect** — how much a retention offer changes that probability.

A customer can have high churn probability and near-zero treatment effect (they will leave regardless of any offer), and a customer can have low churn probability but a meaningful treatment effect (a small nudge keeps them, even though they were unlikely to leave anyway — or worse, the offer could push them the wrong direction). Targeting on risk alone spends the incentive budget without regard to whether it changes anything.

---

## The Four Customer Response Types

Uplift modeling frames customers into four conceptual groups, based on how they would behave *with* and *without* the offer:

| Group | Behavior without offer | Behavior with offer | Should we target? |
|---|---|---|---|
| **Sure Things** | Stay | Stay | No — they were staying anyway; offer is wasted spend |
| **Lost Causes** | Leave | Leave | No — the offer doesn't change the outcome; wasted spend |
| **Persuadables** | Leave | Stay | **Yes** — the offer changes the outcome in our favor |
| **Sleeping Dogs** | Stay | Leave | No — the offer actively backfires for this group |

- **Sure Things** — Customers who would remain loyal regardless of any retention offer. Spending an incentive here has no behavioral impact and simply reduces margin.
- **Persuadables** — Customers whose retention decision is genuinely changed by the offer. These are the only customers for whom the incentive spend is creating value, and are the ideal targeting group.
- **Lost Causes** — Customers who will churn regardless of intervention. Targeting them wastes incentive budget on an outcome that cannot be changed.
- **Sleeping Dogs** — Customers who would have stayed, but whose churn risk actually *increases* if contacted or incentivized (e.g., the offer draws attention to a decision they hadn't been actively considering, or feels intrusive). Targeting this group is actively harmful.

A churn prediction model alone cannot distinguish between these four groups — it only estimates the *without-offer* outcome (roughly, whether someone is likely to be a "Lost Cause" or a "Sure Thing" leans toward leaving vs. staying), not how the offer changes that outcome. Distinguishing Persuadables from the other three groups is precisely the goal of uplift modeling, introduced in [methodology.md](methodology.md).

---

## Prediction vs. Intervention

It is important to separate two distinct analytical questions:

- **Prediction:** "What will happen to this customer if we do nothing?" This is what a churn model answers.
- **Intervention:** "What will happen differently if we act?" This is a causal question, and requires either a randomized experiment or a valid causal-inference method to answer — a predictive model cannot answer it on its own, no matter how accurate.

Confusing these two questions is one of the most common mistakes in applied retention analytics. This project treats them as separate steps: first modeling churn (prediction), then designing and analyzing an experiment (intervention), and finally combining both into an uplift and profit framework.

---

## The Role of Customer Value and Incentive Cost

Even correctly identifying a "Persuadable" customer is not sufficient to justify targeting them. The decision must also account for economics:

- **Customer value** — the value of retaining this customer (e.g., expected future revenue or margin over a defined horizon).
- **Incentive cost** — the cost of the retention offer itself (discount value, credit, fulfillment cost, etc.).

A customer should only be targeted when the expected value created by the increased retention probability exceeds the cost of the incentive:

```
Expected Incremental Profit
  = Estimated uplift in retention probability
    × Estimated customer value
    − Incentive cost
```

This is the central decision rule used throughout the project. It ensures that targeting decisions are driven by expected business value, not simply by risk score or uplift score in isolation. A customer with strong positive uplift but low customer value, or a very expensive incentive, may still not be worth targeting.