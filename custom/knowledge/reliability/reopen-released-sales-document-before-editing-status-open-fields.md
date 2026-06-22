---
bc-version: [all]
domain: reliability
keywords: [teststatusopen, released, reopen, sales-header, unit-price, qty-to-ship, validate, status-open]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reopen a Released sales document before editing fields guarded by TestStatusOpen

## Description

Most editable fields on a sales document run `TestStatusOpen` in their `OnValidate` (directly or via the line's modification check), which raises *"Status must be equal to 'Open' … Current value is 'Released'."* once the document has been **Released** — and posting a shipment/receipt leaves an order Released, not Open. So code (or a test) that ships/posts part of a document and then `Validate`s a price, discount, quantity, or dimension on the same document fails at runtime. The trap: a deliberate subset of fields — `"Qty. to Ship"`, `"Qty. to Invoice"`, `"Return Qty. to Receive"` — are intentionally editable on a Released document (you must set them for partial posting), so a partial-ship-then-set-qty step succeeds while a sibling repricing step on the same Released document throws. The difference is per-field, not obvious from the call site.

## Best Practice

Reopen the document before editing a `TestStatusOpen`-guarded field on a Released document — `Codeunit "Release Sales Document".Reopen(SalesHeader)` (or `LibrarySales.ReopenSalesDocument` in tests) — then make the change; the subsequent post re-releases it automatically. Do not assume a field is editable just because a nearby field (like `"Qty. to Ship"`) was; check whether the field's validation calls `TestStatusOpen`. When a flow legitimately changes price/quantity between partial postings, model it as reopen → edit → post.

See sample: `reopen-released-sales-document-before-editing-status-open-fields.good.al`.

## Anti Pattern

`SalesLine.Validate("Unit Price", …)` (or `"Line Discount %"`, `Quantity`, a dimension) on a `SalesHeader`/`SalesLine` that has been Released — typically after a ship-only `PostSalesDocument(Header, true, false)` — with no `Reopen` in between. Detection signal: a `Validate` of a status-open-guarded field on a document that a preceding post/release left in `Released` status. Contrast `"Qty. to Ship"`/`"Qty. to Invoice"`, which validate fine on a Released document and so are not a signal.

See sample: `reopen-released-sales-document-before-editing-status-open-fields.bad.al`.

## See also

Originates from commissions-management #59 (ENG-8) tests: a true-up test shipped an order then `Validate`d `"Unit Price"` to bill a different amount, erroring on the Released order; `"Qty. to Ship"` had been editable on the same Released order (so the partial-shipment test passed), which masked the cause. Fixed by reopening the order before repricing.
