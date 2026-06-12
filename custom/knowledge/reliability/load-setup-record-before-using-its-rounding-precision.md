---
bc-version: [all]
domain: reliability
keywords: [round, rounding-precision, general-ledger-setup, setup-record, lazy-load, runtime-error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Load a setup record before using its rounding precision in Round

## Description

`Round(Amount, Precision)` raises the runtime error *"The rounding precision must be greater than 0"* when `Precision` is `0`. Rounding-precision fields such as `General Ledger Setup."Unit-Amount Rounding Precision"` and `"Amount Rounding Precision"` evaluate to `0` until the setup record has actually been read into the variable — an unread `Record` variable holds field defaults, and the decimal default is `0`. Codeunits commonly read setup lazily through a cached getter (for example `GetGLSetup()` guarded by a `Read` boolean). If a `Round` call uses the precision field on a code path that has not yet called that getter, it passes `0` and fails at runtime. This is BC-specific and easy to miss because the foreign-currency or "primary" path often reads the setup while a sibling local-currency path does not, so the bug only fires for domestic-currency documents.

## Best Practice

Materialize the setup record before the first read of any of its fields on every path. When a cached getter exists (`GetGLSetup()`), call it immediately before each `Round(...)` that consumes a precision field — the getter is idempotent (it returns early once `Read` is set), so a redundant call on a path that already loaded the setup is free. Treat "uses a setup precision field" as the trigger to ensure the setup is loaded, not "uses currency conversion".

See sample: `load-setup-record-before-using-its-rounding-precision.good.al`.

## Anti Pattern

A `Round(X, GeneralLedgerSetup."Unit-Amount Rounding Precision")` where `GetGLSetup()` (or a direct `GeneralLedgerSetup.Get()`) is only called inside a conditional branch — typically the `if CurrencyCode <> ''` foreign-currency branch — or in a different procedure that does not always run first. The local-currency path then rounds with precision `0` and errors. Detection signal: a precision field of a lazily-loaded setup record is read on a code path where no unconditional load of that record precedes it. Contrast a sibling procedure that correctly calls the getter before its own `Round`.

See sample: `load-setup-record-before-using-its-rounding-precision.bad.al`.

## See also

Originates from royalties-management issue #274 (LCY royalty purchase invoices and journals erroring on `Round(x, 0)`).
