// BAD: Net Payable is derived from Commission Amount, THEN the event fires letting a
// subscriber change Commission Amount, THEN the entry is recorded with no recompute.
// A subscriber that halves the gross leaves Net Payable computed from the old gross.
codeunit 50100 "Bad Mutation Hook Example"
{
    procedure RecordEntry(var CommissionEntry: Record "Commission Ledger Entry")
    var
        IsHandled: Boolean;
    begin
        ApplyNetPayable(CommissionEntry); // Net Payable := f(Commission Amount)

        OnBeforeRecordCommissionEntry(CommissionEntry, IsHandled); // subscriber may change Commission Amount
        if IsHandled then
            exit;

        CommissionEntry.Insert(true); // Net Payable is now stale vs the modified Commission Amount
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecordCommissionEntry(var CommissionEntry: Record "Commission Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    local procedure ApplyNetPayable(var CommissionEntry: Record "Commission Ledger Entry")
    begin
        CommissionEntry."Net Payable Amount" := CommissionEntry."Commission Amount"; // (cap/draw omitted)
    end;
}
