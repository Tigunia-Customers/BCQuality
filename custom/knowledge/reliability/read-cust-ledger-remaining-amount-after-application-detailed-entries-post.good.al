// GOOD: react after the application is committed — subscribe to the Detailed Cust. Ledg.
// Entry insert for Entry Type = Application, where the applied invoice's Remaining Amount
// reflects the payment.
codeunit 50101 "Good Apply Timing Example"
{
    [EventSubscriber(ObjectType::Table, Database::"Detailed Cust. Ledg. Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertDtldCLE(var Rec: Record "Detailed Cust. Ledg. Entry")
    var
        InvoiceCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if Rec."Entry Type" <> Rec."Entry Type"::Application then
            exit;
        if not InvoiceCustLedgerEntry.Get(Rec."Cust. Ledger Entry No.") then
            exit;
        InvoiceCustLedgerEntry.CalcFields("Remaining Amount"); // now reflects the applied payment
        if InvoiceCustLedgerEntry."Remaining Amount" = 0 then
            PromoteCommission(InvoiceCustLedgerEntry."Entry No.");
    end;

    local procedure PromoteCommission(InvoiceCustLedgerEntryNo: Integer)
    begin
    end;
}
