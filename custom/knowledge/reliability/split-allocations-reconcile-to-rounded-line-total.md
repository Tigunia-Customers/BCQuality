---
bc-version: [all]
domain: reliability
keywords: [rounding, split, allocation, largest-remainder, penny-allocation, reconcile, percentage-split]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Split allocations must reconcile to the rounded line total, not round each share independently

## Description

When one amount (a line commission, a discount, a charge) is divided across several parties by percentage, rounding **each share independently** — `Round(Total × Pct / 100)` per party — can make the rounded shares fail to sum back to the rounded total. On an odd-cent amount the residual is non-zero: $100.01 split three ways at 33.33/33.33/33.34 gives 33.34 × 3 = $100.02 (a +$0.01 drift), and $0.01 split 50/50 gives $0.01 × 2 = $0.02 (over-allocation). The per-party rows then don't tie to the line, so audit detail and downstream reconciliation are off by a cent. This applies wherever a **single shared total** is apportioned — an equal-rate split, a manual-amount split. It does **not** apply to a per-party independent computation (each party at their own rate with no common total to reconcile against).

## Best Practice

Apply largest-remainder (penny) reconciliation when a single total is divided: round each share, sum them, and assign the residual (rounded total − Σ rounded shares) to one share — the largest, or simply the last — so the rows always sum to the rounded total. The simplest correct form: give every share but the last its independently rounded value, and set the last share to `RoundedTotal − Σ(previous shares)`. Reconcile only where a common total exists; leave a genuine per-party different-rate split (no shared total) untouched.

See sample: `split-allocations-reconcile-to-rounded-line-total.good.al`.

## Anti Pattern

A loop that emits `Round(Total * Party.Pct / 100)` for each party with no post-pass reconciling the sum to `Round(Total)`. Detection signal: independent per-share rounding of a shared total where the shares are expected to reconstruct that total (audit rows, a "rows sum to the line" invariant), with no largest-remainder/residual step. The defect only shows on odd-cent totals or splits that don't divide evenly, so even-split tests pass and hide it.

See sample: `split-allocations-reconcile-to-rounded-line-total.bad.al`.

## See also

Originates from commissions-management #71: equal-rate and manual-amount multi-agent splits rounded each agent's share independently, so an odd-cent line commission's shares did not sum to the rounded line total. Fixed with a last-share-absorbs-residual reconciliation, applied only when all rows share one line total (per-agent different-rate splits, UC-13, were left as-is).
