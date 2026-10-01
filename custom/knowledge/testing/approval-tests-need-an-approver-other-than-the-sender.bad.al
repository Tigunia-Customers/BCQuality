// BAD: the current user is the sender and their own direct approver.
// Approvals Mgmt. approves the request at once, so no entry is Open and
// ApproveRecordApprovalRequest fails with "There is no approval request to approve."
codeunit 50100 "Budget Approval Test Bad"
{
    Subtype = Test;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";

    [Test]
    procedure ApproveSetsApproved()
    var
        GLBudgetName: Record "G/L Budget Name";
    begin
        SetUpCurrentUserAsOwnApprover();
        CreateBudget(GLBudgetName);
        SendApprovalRequest(GLBudgetName);

        ApprovalsMgmt.ApproveRecordApprovalRequest(GLBudgetName.RecordId); // fails: the entry is already Approved
    end;

    local procedure SetUpCurrentUserAsOwnApprover()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."Approver ID" := UserSetup."User ID"; // self-approval
        UserSetup."Approval Administrator" := true;
        UserSetup.Modify();
    end;

    local procedure CreateBudget(var GLBudgetName: Record "G/L Budget Name")
    begin
    end;

    local procedure SendApprovalRequest(GLBudgetName: Record "G/L Budget Name")
    begin
    end;
}
