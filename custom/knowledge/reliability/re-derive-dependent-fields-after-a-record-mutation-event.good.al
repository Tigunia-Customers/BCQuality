// GOOD: after the (un-suppressed) mutation event, the derivation is re-run so Net Payable
// always follows the FINAL Commission Amount, whether or not a subscriber changed it.
codeunit 50101 "Good Mutation Hook Example"
{
    procedure RecordEntry(var CommissionEntry: Record "Commission Ledger Entry")
    var
        IsHandled: Boolean;
    begin
        ApplyNetPayable(CommissionEntry);

        OnBeforeRecordCommissionEntry(CommissionEntry, IsHandled);
        if IsHandled then
            exit;

        // The subscriber may have changed the gross; re-derive so the entry is internally consistent.
        ApplyNetPayable(CommissionEntry);

        CommissionEntry.Insert(true);
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
