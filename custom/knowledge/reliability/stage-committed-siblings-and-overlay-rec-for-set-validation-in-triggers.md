---
bc-version: [all]
domain: reliability
keywords: [oninsert, onmodify, in-flight-rec, set-validation, staging, temporary-record, split-total, trigger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Stage committed siblings and overlay Rec for whole-set validation in OnInsert/OnModify

## Description

A validation that must consider a **whole set** of rows — "the splits in this scope total 100%", "these bands are contiguous", "only one row is the default" — cannot scan the live table from inside the row's own `OnInsert`/`OnModify` trigger to get the right answer. During the trigger the in-flight `Rec` is **not yet committed**: a separate `Record` variable that filters and scans the table does **not** see a being-inserted row at all, and sees the **stale** committed image of a being-modified row. So a sum/contiguity/uniqueness check built on a live scan validates against the pre-change set and either rejects a valid change or accepts an invalid one.

## Best Practice

Build the post-change image explicitly: scan the committed siblings in the scope **excluding the in-flight row's own primary key** into a temporary record, then **overlay the in-flight `Rec`** (insert it into the temp set), and run the set validation over the temporary set. That way the new/changed row's in-flight value is the one counted, exactly as it will be once committed. For a delete, stage the siblings and omit `Rec` so the set reflects the row being gone. Centralize this staging in one helper that every trigger (OnInsert/OnModify/OnValidate/OnDelete) calls, so the rule is defined once.

See sample: `stage-committed-siblings-and-overlay-rec-for-set-validation-in-triggers.good.al`.

## Anti Pattern

An `OnInsert`/`OnModify` (or a field `OnValidate`) that does `Sibling.SetRange(<scope>); Sibling.CalcSums(...)` / `FindSet` on a fresh table variable and validates the result, expecting the in-flight `Rec` to be included. Detection signal: a whole-set check (total, contiguity, uniqueness) inside a row trigger that reads the live table without excluding-Rec's-key-and-overlaying-Rec. The check passes the existing rows but mis-handles the row currently being inserted/modified.

See sample: `stage-committed-siblings-and-overlay-rec-for-set-validation-in-triggers.bad.al`.

## See also

Originates from commissions-management Plan Builder / Agent Manager (PB-3): the 100%-per-scope split total and tier-band integrity checks ran from OnInsert/OnModify and had to stage committed siblings + overlay Rec rather than scan the live table. Pairs with `tier-bands-must-be-contiguous-no-gaps-or-overlaps`.
