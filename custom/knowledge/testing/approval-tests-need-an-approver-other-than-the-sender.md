---
bc-version: [all]
domain: testing
keywords: [approval, workflow, approval-entry, user-setup, approver-id, self-approval, approvals-mgmt, direct-approver]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Approval tests need an approver other than the sender

## Description

A test runs as one user, so that user is the sender of every approval request the test sends. `Approvals Mgmt.` `MakeApprovalEntry` sets a new approval entry to `Approved` when its approver ID is the current user (`if ApproverId = UserId then ApprovalEntry.Status := Approved`). A test that sets the current user's `User Setup` `Approver ID` to the user itself therefore gets a request that is approved at once: no entry is `Open`, the record goes straight to its approved state, and `ApproveRecordApprovalRequest` / `RejectRecordApprovalRequest` fail with "There is no approval request to approve/reject". A second trap has the same result: for a *Direct Approver* step, `CreateApprovalRequestForApprover` reads the approver's own `User Setup` row, and when that row is missing and the sender is an approval administrator, it gives the request to the sender — and the sender's entry is approved at once too. Both compile cleanly; only a test run shows them.

## Best Practice

Make the direct approver a mock user that has its **own** `User Setup` row (assign `User ID` directly and `Insert()`, no `Validate`, because the field relates to the `User` table). Keep the sender an approval administrator when a test cancels a request. Before `ApproveRecordApprovalRequest` or `RejectRecordApprovalRequest`, give the open entry to the current user — set `Approver ID` to `UserId()` — because both procedures filter on `"Approver ID" = UserId`. Where the `Tests-TestLibraries` app is available, `Library - Document Approvals` (`CreateMockupUserSetup`, `SetApprover`, `UpdateApprovalEntryWithCurrUser`) does the same; it is not in the `Application Test Library` app, so an extension test app that depends only on that library hand-rolls these helpers.

See sample: `approval-tests-need-an-approver-other-than-the-sender.good.al`.

## Anti Pattern

A test helper that sets `UserSetup."Approver ID" := UserSetup."User ID"` (or `:= UserId()`) on the current user before it sends an approval request, followed by asserts that expect an `Open` approval entry, a pending status, or a successful approve/reject. Also a mock approver ID assigned to `Approver ID` with no `User Setup` row of its own. Detection signal: the test comment or helper name says the user "is the sender and the approver" / "own approver".

See sample: `approval-tests-need-an-approver-other-than-the-sender.bad.al`.

## See also

Originates from encumbrance (EncumbranceCentral) issues #21 and #24: eight budget approval and approval-history tests failed in CI because the test user was their own direct approver. Related: `../../../microsoft/knowledge/testing/asserterror-needs-expectederror-and-code.md`.
