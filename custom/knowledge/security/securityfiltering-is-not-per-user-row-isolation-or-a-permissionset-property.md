---
bc-version: [all]
domain: security
keywords: [securityfiltering, security-filter, permissionset, row-level-security, data-isolation, rep-scope, page-property]
technologies: [al]
countries: [w1]
application-area: [all]
---

# SecurityFiltering is not a permission-set property and does not by itself isolate rows per user

## Description

Per-user **row-level** data isolation ("each rep sees only their own records") is a common requirement that AL gives no single declarative switch for, and two plausible-looking approaches do not deliver it. First, `SecurityFiltering` is **not** a `permissionset` property — a permission set grants object/tabledata permissions (RIMD) and cannot be authored to filter rows; writing `SecurityFiltering` in a permissionset object does not compile. Second, `SecurityFiltering` on a page/query is a property that governs **how the user's already-configured security filters are applied** (Filtered/Validated/Ignored/Disallowed) — it does not, on its own, create those filters, so adding it to a List page without configured security filters restricts nothing. Teams reach for one of these to scope a salesperson/rep to their own commission, sales, or ledger rows and find the rows are not actually isolated.

## Best Practice

Decide the isolation mechanism explicitly. True per-user row security in BC requires **configured security filters** (the security-filter setup tied to the user's permission sets) — `SecurityFiltering` on the page/query then controls how strictly those filters apply. If configured security filters are not in scope, isolate at the application layer (filter the source by the user's salesperson/responsibility, or expose the scoped data through a dedicated access layer/portal) and do not imply isolation that is not enforced. Either way, do not treat a permission set or a bare page `SecurityFiltering` property as row-level security.

See sample: `securityfiltering-is-not-per-user-row-isolation-or-a-permissionset-property.good.al`.

## Anti Pattern

A `SecurityFiltering` property added to a List page (or a permission set) with the intent of limiting a user to their own rows, but with no configured security filters behind it — the rows are not isolated. Detection signal: a row-isolation requirement met only by a page `SecurityFiltering` property or a permission-set grant, with no configured security filter or explicit source filtering. Also flag any attempt to place `SecurityFiltering` in a `permissionset` object (it is not a valid property there).

See sample: `securityfiltering-is-not-per-user-row-isolation-or-a-permissionset-property.bad.al`.

## See also

Originates from commissions-management: rep data isolation (each rep seeing only their own commissions) could not be met by `SecurityFiltering` or the permission sets alone and was deferred to a dedicated portal access layer (BL-07). The role-based permission sets scope *object* access, not rows.
