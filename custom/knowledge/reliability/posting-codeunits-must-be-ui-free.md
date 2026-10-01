---
bc-version: [all]
domain: reliability
keywords: [posting-codeunit, message, confirm, dialog, guiallowed, test-runner, unhandled-ui, headless, processing-codeunit, separation-of-ui]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Posting and processing codeunits must be UI-free — GuiAllowed() does not make them safe

## Description

A codeunit that posts, validates, calculates, or otherwise does document/processing work is routinely invoked on paths that have **no one to answer a dialog**: the automated test runner, a job-queue/scheduled run, an integration-event subscriber, or another posting routine that calls it inside an open posting transaction. If such a codeunit raises `Message`, `Confirm`, `StrMenu`, or any other UI, it breaks on those paths.

The trap is that `GuiAllowed()` looks like the fix but is not. **`GuiAllowed()` returns `true` inside the BC test runner** — a test session is an interactive client session — so `if not GuiAllowed() then exit;` does **not** suppress the dialog during automated tests. The `Message`/`Confirm` still fires, and because no `[MessageHandler]`/`[ConfirmHandler]` is registered the runner aborts the test with *"Unhandled UI: Message"* (or *Confirm*). Worse, even where `GuiAllowed()` is genuinely `false` (a true background session), silently swallowing the dialog means the caller — e.g. the Engine posting a staged batch inside its own transaction — gets different behaviour than the interactive path, which is its own defect. Static analysis does not catch this; only executing the test surfaces it.

Note this rule is about **interactive UI** (`Message`, `Confirm`, `StrMenu`, `Page.RunModal` for input, `Dialog` windows). `Error` and `FieldError` are **not** covered — they are the rollback mechanism, are legal on every path, and tests assert them with `asserterror`.

## Best Practice

Keep posting/processing codeunits UI-free. Compute the outcome and **return it to the caller** (counts, a status, a result record/text via `var` parameters), and let the **page or action layer present the `Message`/`Confirm`** — a page action always runs in a UI session, and tests drive the codeunit directly so no handler is needed. A test that must assert the user-facing text drives the page (with a `[MessageHandler]`) or asserts the returned data, never a dialog buried in the posting path.

So: the posting codeunit exposes a headless entry that returns the posted/skipped counts; the journal page's Post action calls that entry and shows the summary message itself.

See sample: `posting-codeunits-must-be-ui-free.good.al`.

## Anti Pattern

A `Message(...)` or `Confirm(...)` inside a posting/processing codeunit — one with `TableNo` + `OnRun`, a name containing `Post`/`Check`/`Calc`/`Process`/`Jnl`, or reachable from a posting/document flow — **especially** when it is wrapped in `if not GuiAllowed() then exit;`. That guard is the tell that someone tried to make a non-UI object "UI-safe"; it does nothing in the test runner (where `GuiAllowed()` is `true`) and masks a design problem on real background paths. Detection signal: an interactive UI call (not `Error`/`FieldError`) on any code path of a codeunit that is invoked by Post-Batch/Post-Line, a job queue, an event subscriber, or another posting transaction.

See sample: `posting-codeunits-must-be-ui-free.bad.al`.

## See also

Originates from commissions-management issue #53 (ENG-2): the commission-journal Post-Batch codeunit guarded its posted/skipped summary `Message` with `GuiAllowed()`; CI test `ManualLinePostsOneLedgerEntryAndClearsLine` still failed with *"Unhandled UI: Message"* because `GuiAllowed()` is `true` in the test runner. Fixed by making the Post-Batch codeunit UI-free and moving the summary message to the Commission Journal page's Post action.
