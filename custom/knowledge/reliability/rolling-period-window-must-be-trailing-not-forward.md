---
bc-version: [all]
domain: reliability
keywords: [dateformula, calcdate, rolling-period, trailing-window, cap-period, cumulative, period-filter, negate]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A rolling-period window must apply the period formula backward (trailing), not forward

## Description

A "period" `DateFormula` a user enters for a rolling window — a commission/royalty Cap Period, a cumulative-sales window, an aging bucket — is a **positive duration** (`1M`, `1Y`, `3M`). To build the trailing window that ENDS on an anchor date you must apply that duration **backward** from the anchor. Applying it forward with `CalcDate(Period, AnchorDate)` lands the computed start one period in the **future**, after the anchor, so the resulting `SetRange(<date>, Start, Anchor)` is an inverted, empty range. The filter then matches nothing: a period cap sees zero prior consumption and silently never binds; a tiered cumulative resets to the bottom band on every transaction. It is insidious because the code compiles, the happy path (a single transaction, or a blank/default period) looks correct, and only a multi-transaction period in the same window reveals the wrong total.

## Best Practice

Treat a user-entered period as a duration and negate it to build a trailing window: step back one period from the anchor, then forward a day for an inclusive start (`CalcDate('<1D>', CalcDate(<negated>, Anchor))`). Normalize the sign so a positive `1M` and an explicit `-1M` both yield the same trailing window. Put the window math in ONE shared helper so every caller (the cap consumer, the tier cumulative, the preview) shares the correct computation — duplicated copies turn one fix into an N-site fix. Cover it with a test that spans **two** transactions in one period; a single-transaction test cannot reveal a forward/empty window.

See sample: `rolling-period-window-must-be-trailing-not-forward.good.al`.

## Anti Pattern

`PeriodStart := CalcDate('<-1D>', CalcDate(Period, AnchorDate))` — or any `CalcDate(<positive user period>, AnchorDate)` — used as the START (low bound) of a `[Start, Anchor]` date filter. Detection signal: a `DateFormula` sourced from a user/setup field, applied with `CalcDate` in the forward direction, then used as the low bound of a date range ending at/near the anchor. The range is empty whenever the formula is positive, so a cap/cumulative that should accumulate across the period reads as if the period were empty.

See sample: `rolling-period-window-must-be-trailing-not-forward.bad.al`.

## See also

Originates from commissions-management #51 (Commission Engine close-out): ENG-9 `CapPeriodStart` and three duplicated `TierPeriodWindow` copies applied a positive Cap Period forward, so period caps never bound and tiered plans reset every sale. No test used a non-blank Cap Period, so CI stayed green until a deliberate two-entry test was added. Pairs with the duplication lesson — the fix had to touch four sites.
