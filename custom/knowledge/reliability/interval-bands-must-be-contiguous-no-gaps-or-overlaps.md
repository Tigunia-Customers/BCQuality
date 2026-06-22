---
bc-version: [all]
domain: reliability
keywords: [tier, bands, breakpoints, intervals, contiguous, gaps, overlaps, from-to, validation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Interval/breakpoint bands must be validated for contiguity (no gaps, no overlaps) across the whole set

## Description

When a feature models an ordered set of **breakpoint bands** — tier rate bands with a From/To amount, aging buckets, quantity breaks — the bands must form a contiguous cover: the first starts at the floor (0), each band's From equals the previous band's To, no two bands overlap, and only the highest band may be open-ended. A per-row check (`From < To`) is **not enough**: a gap or overlap is a property of the *set*, and the most dangerous case is a **delete** that removes an interior band and silently opens a gap, so amounts in that range fall through to the wrong band (or no band) at calculation time. The integrity must be re-validated on every insert, modify, AND delete, against the whole ordered set.

## Best Practice

On insert/modify/delete, validate the full ordered band set in one pass: sort by From; require the first From = the floor; require each subsequent From to equal the prior band's To (no gap, no overlap); allow only the last band to be open-ended (blank/max To). Build the post-change set with the stage-committed-siblings-and-overlay-Rec pattern so the in-flight row (or the row being deleted, staged out) is reflected — see `stage-committed-siblings-and-overlay-rec-for-set-validation-in-triggers`. Reject the change with a clear error rather than letting a gap/overlap reach the calculation.

See sample: `interval-bands-must-be-contiguous-no-gaps-or-overlaps.good.al`.

## Anti Pattern

A band table that validates only the changed row (e.g. `TestField`/`From < To`) and has no whole-set contiguity check, or that has an OnInsert/OnModify check but **no OnDelete** check. Detection signal: From/To band rows where calculation assumes a contiguous cover but nothing rejects a gap (deleted interior band) or an overlap (a new band straddling two existing ones). The defect surfaces only at calc time for amounts landing in the gap/overlap.

See sample: `interval-bands-must-be-contiguous-no-gaps-or-overlaps.bad.al`.

## See also

Originates from commissions-management Plan Builder (PB-3) tier breakpoint bands: From/To rate bands validated for no gaps/overlaps, first band at 0, highest open-ended, and a deleted interior band rejected for opening a gap. Pairs with `stage-committed-siblings-and-overlay-rec-for-set-validation-in-triggers` (how to see the in-flight set in the trigger).
