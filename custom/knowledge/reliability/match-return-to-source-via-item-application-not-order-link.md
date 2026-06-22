---
bc-version: [all]
domain: reliability
keywords: [credit-memo, return-order, appl-from-item-entry, item-ledger-entry, order-no, sales-shipment, document-link]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Match a return/credit memo to its source document via item application, not the order link

## Description

To reverse or relate a posted **return / credit memo** back to the original document it returns (a posted shipment, the original sale), do **not** key on the posted line's `"Order No."`/`"Order Line No."`. Those fields are **blank** on a return-order-sourced credit memo: the unposted `Sales Line` has no `"Order No."` field to carry, and `Sales-Post` stamps a posted line's `"Order No."` only when posting an **Order** document — a Return Order populates `"Return Order No."`/`"Return Receipt No."` instead. A join on `Sales Cr.Memo Line."Order No."` therefore matches nothing and the link silently never resolves (e.g. the original commission/cost is never reversed). The link that **does** survive a return-of-goods flow is the **item application**: the line's `"Appl.-from Item Entry"` points at the originating outbound `Item Ledger Entry`, whose `"Document No."`/`"Document Type"` identify the posted shipment/invoice.

## Best Practice

Resolve a return/credit-memo line to its source document through `"Appl.-from Item Entry"` → `Item Ledger Entry.Get(...)` → `ItemLedgerEntry."Document No."` (gated on the expected `"Document Type"`, e.g. `"Sales Shipment"`). This is the same chain BC uses for exact-cost reversing, so it is present whenever the return is applied to the goods. In tests, establish the application explicitly (copy from the posted shipment, or set `"Appl.-from Item Entry"` to the shipment line's `"Item Shpt. Entry No."`) — a return order copied from a posted shipment does not always carry it for free.

See sample: `match-return-to-source-via-item-application-not-order-link.good.al`.

## Anti Pattern

`SalesCrMemoLine.SetFilter("Order No.", '<>%1', '')` (or `SetRange("Order No.", SomeOrderNo)`) used to find the order/shipment a credit memo reverses. Detection signal: a posted `Sales Cr.Memo Line` (or `Return Receipt Line`) filtered/joined on `"Order No."`/`"Order Line No."` to reach a source Order or Shipment. Those fields are empty for the return-order flow, so the match resolves to nothing and the dependent action (reversal, cost link, traceability) is silently skipped.

See sample: `match-return-to-source-via-item-application-not-order-link.bad.al`.

## See also

Originates from commissions-management #59 (ENG-8): the on-shipment commission reversal matched credit-memo lines on `"Order No."` (blank on a return-order credit memo), so the original shipment commission was never flagged Reversed. Fixed by matching via `"Appl.-from Item Entry"` → the shipment's Item Ledger Entry `"Document No."`. Confirmed against the base-app symbols: the unposted `Sales Line` has no `"Order No."` field.
