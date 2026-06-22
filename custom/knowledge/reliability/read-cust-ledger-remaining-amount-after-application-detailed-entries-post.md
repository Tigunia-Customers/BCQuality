---
bc-version: [all]
domain: reliability
keywords: [cust-ledger-entry, remaining-amount, application, detailed-cust-ledg-entry, onafterapplycustledgentry, gen-jnl-post-line, payment]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Read a customer ledger entry's Remaining Amount after the application detailed entries post, not during the apply calc

## Description

`Codeunit "Gen. Jnl.-Post Line"."OnAfterApplyCustLedgEntry"` fires during the application **calculation**, BEFORE the application `Detailed Cust. Ledg. Entry` records are posted. At that point the applied invoice's `Cust. Ledger Entry."Remaining Amount"` is still its **pre-payment** value — the payment has not yet reduced it. Code that reacts to this event to decide "how much of the invoice is now paid" (a cash-collected %, a paid-in-full check, a payment-triggered promotion) therefore reads the old remaining and computes 0% collected, firing too early or not at all. The event name suggests "after apply," but it is after the apply *math*, not after the ledger reflects it.

## Best Practice

React to the application **after** it is committed to the ledger: subscribe to `Detailed Cust. Ledg. Entry."OnAfterInsertEvent"` and act only on `"Entry Type" = Application`. From the application detailed entry, resolve the applied invoice's `Cust. Ledger Entry` (its `CalcFields("Remaining Amount")` now reflects the payment) and compute the collected amount/percentage there. This is the seam where the post-payment remaining is correct.

See sample: `read-cust-ledger-remaining-amount-after-application-detailed-entries-post.good.al`.

## Anti Pattern

An `[EventSubscriber]` on `"Gen. Jnl.-Post Line"."OnAfterApplyCustLedgEntry"` that reads `CustLedgerEntry."Remaining Amount"` (or `CalcFields` it) to gauge payment. Detection signal: any payment/collection decision keyed on a customer ledger Remaining Amount inside the apply-calc event. The value is pre-application, so the decision uses stale data (typically reading the invoice as still fully open).

See sample: `read-cust-ledger-remaining-amount-after-application-detailed-entries-post.bad.al`.

## See also

Originates from commissions-management #58 (ENG-7 On-Payment Cash % promotion): the Cash % was first computed in `OnAfterApplyCustLedgEntry`, where the invoice Remaining Amount was still pre-payment, so it read 0% and never promoted; CI caught it. Fixed by reacting to `Detailed Cust. Ledg. Entry.OnAfterInsertEvent` (Entry Type = Application).
