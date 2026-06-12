---
bc-version: [all]
domain: reliability
keywords: [return-value, boolean, exit, success-flag, default-value, runwithcheck]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Assign a return value on every path of a result-returning procedure

## Description

An AL procedure declared with a return type returns the type's default when no path assigns a value — for `Boolean` that default is `false`. The compiler does **not** require every path to set the return value and emits no error for a procedure that never assigns one, so a `Boolean`-returning procedure with no `exit(...)` or return-variable assignment compiles cleanly and silently always returns `false`. When that return is used as a success flag, every caller reads success as failure. The classic shape is a post/process routine — `RunWithCheck(...)`/`PostJnlLine(...)` — declared `: Boolean` whose body does work and ends without ever returning `true`; a batch driver guarded by `if not RunWithCheck(...) then <handle failure>` then treats every successfully processed line as a failure and runs its error/after-failure path on each one.

## Best Practice

When a procedure's return value is meaningful (a success flag, a found/processed indicator), assign it on every path the caller depends on. For a success flag, end the happy path with `exit(true)` and let early guards `exit(false)` (or `exit` for the default). When one procedure delegates the real work to another that already returns the result, propagate it: `exit(DoTheWork(...))` rather than calling `DoTheWork(...)` and falling through. Verify the caller's polarity matches: an after-success hook belongs under `if RunWithCheck(...) then ...`, not `if not RunWithCheck(...) then ...`.

See sample: `assign-a-return-value-on-every-path-of-a-boolean-procedure.good.al`.

## Anti Pattern

A procedure with a declared return type whose body has no `exit(<value>)` and no assignment to the return variable on its main path — it falls off the end and returns the default. Detection signal: a non-`void` procedure (especially `: Boolean` named `Run*`, `Try*`, `Post*`, `Check*`, `Is*`, `Has*`) whose last statement is a plain procedure call or `Modify`/`Insert`, with no `exit(...)` anywhere on the success path; and/or a caller that branches on it with `if not Proc(...) then` running what reads like a post-success action. The result compiles and ships, so only behaviour (success reported as failure) reveals it.

See sample: `assign-a-return-value-on-every-path-of-a-boolean-procedure.bad.al`.

## See also

Originates from royalties-management issue #277 (`RunWithCheck`/`PostJnlLine` never assigned a return value, so the journal batch poster treated every posted line as a failure).
