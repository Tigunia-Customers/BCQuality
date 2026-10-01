// GOOD: the direct approver is a mock user with its own User Setup row.
// Before approve or reject, the open entry is given to the current user,
// because both procedures act only on the current user's open entry.
codeunit 50101 "Budget Approval Test Good"
{
    Subtype = Test;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        MockApproverIdTok: Label 'MOCK-APPROVER', Locked = true;

    [Test]
    procedure ApproveSetsApproved()
    var
        GLBudgetName: Record "G/L Budget Name";
    begin
        SetUpMockApprover();
        CreateBudget(GLBudgetName);
        SendApprovalRequest(GLBudgetName);

        AssignOpenRequestToCurrentUser(GLBudgetName.RecordId);
        ApprovalsMgmt.ApproveRecordApprovalRequest(GLBudgetName.RecordId);
    end;

    local procedure SetUpMockApprover()
    var
        UserSetup: Record "User Setup";
        ApproverUserSetup: Record "User Setup";
    begin
        // The mock approver needs its own row: with no row, the request goes to the sender and is approved at once.
        if not ApproverUserSetup.Get(MockApproverIdTok) then begin
            ApproverUserSetup.Init();
            ApproverUserSetup."User ID" := MockApproverIdTok;
            ApproverUserSetup.Insert();
        end;
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."Approver ID" := ApproverUserSetup."User ID";
        UserSetup."Approval Administrator" := true; // lets the sender cancel
        UserSetup.Modify();
    end;

    local procedure AssignOpenRequestToCurrentUser(RecId: RecordId)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", RecId.TableNo);
        ApprovalEntry.SetRange("Record ID to Approve", RecId);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.ModifyAll("Approver ID", CopyStr(UserId(), 1, MaxStrLen(ApprovalEntry."Approver ID")));
    end;

    local procedure CreateBudget(var GLBudgetName: Record "G/L Budget Name")
    begin
    end;

    local procedure SendApprovalRequest(GLBudgetName: Record "G/L Budget Name")
    begin
    end;
}
