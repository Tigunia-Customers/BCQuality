---
bc-version: [all]
domain: reliability
keywords: [margin, gross-profit, cogs, cost-amount, value-entry, item-ledger, calcsums, cumulative-cost, commission, pure-calculation, cost-basis]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Margin/GP cost basis must be the line's COGS, not the item's cumulative ledger cost

## Description

A per-line margin (gross-profit) calculation needs the COGS of the **specific sale** — the cost of the quantity sold on that one line. A tempting shortcut is to source it by summing the item's value entries up to the posting date: `Value Entry.SetRange("Item No.", X); Value Entry.SetRange("Posting Date", 0D, D); Value Entry.CalcSums("Cost Amount (Actual)")`. That is wrong. `CalcSums` over `"Item No." + "Posting Date"` aggregates **every** value entry for the item — all receipts, shipments, adjustments, revaluations, across every document and customer — which is the item's *cumulative inventory cost*, not this line's COGS. The two coincide only in the degenerate single-transaction case, which is exactly what a naive unit test sets up (a brand-new item with one or two value entries), so the bug ships green. With any real inventory history the "cost" grows without bound and the margin — and the commission, and any minimum-GP gate — goes arbitrarily wrong, often negative.

There is also a sequencing trap: when the per-line cost is needed **during** posting (e.g. a commission posted in the same transaction as the sale), the sale's own COGS value entries **do not exist yet**, so they cannot be read at all — the cumulative sum would see only prior history and silently undercount.

## Best Practice

Have the **posting trigger that owns the source document supply the cost** to a pure calculation. The trigger holds the sales/shipment/invoice line (or the posting buffer) and its value entries and knows the exact COGS for the quantity on that line; it passes that cost in. The pure calc consumes the supplied cost and performs **no item-ledger lookup of its own** — it cannot, lacking the document identity. A margin calc invoked **without** a supplied cost should fail loudly with a contract `Error`, never fall back to a cumulative or zero cost. If the cost genuinely must be derived inside a read, scope the `Value Entry` filter to the **specific source document** (document no. + line no. + the sale's item-ledger-entry-type), not to the item.

See sample: `margin-cost-basis-must-be-line-cogs-not-cumulative-item-cost.good.al`.

## Anti Pattern

A margin/GP routine that, when the caller does not supply a cost, sums `Value Entry."Cost Amount (Actual)"` filtered **only by item (and date)** and treats the result as one line's cost basis. Detection signal: a `CalcSums("Cost Amount (Actual)")` (or any item-ledger cost aggregate) keyed by `"Item No."` without a source-document filter, consumed as a single line's COGS. A companion smell is a test that "proves" the cost basis using a freshly created item with one or two value entries — a single-transaction fixture that cannot distinguish cumulative cost from line COGS.

See sample: `margin-cost-basis-must-be-line-cogs-not-cumulative-item-cost.bad.al`.

## See also

Originates from commissions-management issue #54 (ENG-3): the commission calc sourced the Percent-of-Margin cost with `Value Entry.CalcSums("Cost Amount (Actual)")` filtered by item + posting date — the item's cumulative cost, not the sold line's COGS — and a single-transaction test masked it. Fixed by removing the ledger read from the pure calc and having the posting trigger (which holds the source document) supply the posted COGS, rejecting a margin calc with no supplied cost.
