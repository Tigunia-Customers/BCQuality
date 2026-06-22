// BAD: OnAfterApplyCustLedgEntry fires during the apply CALC, before the application
// detailed entries post, so the invoice's Remaining Amount is still pre-payment.
// The cash % reads as 0 and the payment-triggered promotion never fires.
codeunit 50100 "Bad Apply Timing Example"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterApplyCustLedgEntry', '', false, false)]
    local procedure OnAfterApply(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.CalcFields("Remaining Amount"); // still the PRE-payment remaining here
        if CustLedgerEntry."Remaining Amount" = 0 then
            PromoteCommission(CustLedgerEntry."Entry No."); // never reached on a paying application
    end;

    local procedure PromoteCommission(InvoiceCustLedgerEntryNo: Integer)
    begin
    end;
}
