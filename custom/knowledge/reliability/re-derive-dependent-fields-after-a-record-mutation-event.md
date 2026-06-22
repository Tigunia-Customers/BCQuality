---
bc-version: [all]
domain: reliability
keywords: [integration-event, onbefore, mutation-hook, derived-field, stale, ishandled, extensibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Re-derive dependent fields after a record-mutation extension event

## Description

When code computes a **derived** field from a source field and also raises an `OnBefore…` integration event that lets a subscriber **modify the record** before it is recorded, the order matters. If the derivation runs first and the event fires after it, a subscriber that changes the source field leaves every dependent field computed from the **pre-modification** value — they are silently stale. The record is then inserted (and any side effect, e.g. a balance decrement, applied) with an internally inconsistent source-vs-derived state. This is a BC-specific extensibility trap: the event contract advertises "you may modify amount/status/dimensions," but the platform cannot know that a downstream field was derived from what the subscriber just changed.

## Best Practice

Establish a single invariant — *the dependent field is always re-derived from the final source value* — and enforce it relative to the event. Either (a) fire the mutation event **before** the derivation, so the derivation naturally consumes the modified value, or (b) **re-run the derivation after** the (un-suppressed) event returns, just before recording. Option (b) is cheap when the derivation is a pure in-memory recompute. Document that the dependent field is engine-derived (not a value the subscriber sets directly), so the contract is unambiguous. Add a test with a subscriber that modifies only the source field and asserts the dependent field is consistent.

See sample: `re-derive-dependent-fields-after-a-record-mutation-event.good.al`.

## Anti Pattern

`DeriveDependent(Entry)` → `OnBeforeRecord(Entry, IsHandled)` → `Entry.Insert()` with no re-derivation between the event and the insert. Detection signal: an `OnBefore…`/`OnBeforeInsert…` event passing the record `var` (modifiable) that fires **after** a field on that record was computed from another field on the same record, with no recompute before the write. A pure-suppression (`IsHandled`) subscriber is unaffected; only an amount/source-modifying subscriber exposes the stale derived field.

See sample: `re-derive-dependent-fields-after-a-record-mutation-event.bad.al`.

## See also

Originates from commissions-management #51 (Commission Engine close-out): the ENG-2 posting gateway raised `OnBeforeRecordCommissionEntry` after the ENG-9 net-payable derivation, so a subscriber halving `Commission Amount` left `Net Payable`/`Cap Deduction`/`Draw Offset` stale and decremented the draw by a stale offset. Fixed by re-running the net-payable derivation after the event.
