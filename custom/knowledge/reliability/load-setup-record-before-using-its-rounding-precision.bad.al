// BAD: GetGLSetup() is only called inside the foreign-currency branch.
// On the local-currency path (CurrencyCode = ''), GeneralLedgerSetup has never
// been read, so "Unit-Amount Rounding Precision" is 0 and Round() errors at runtime.
codeunit 50100 "Bad Rounding Example"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

    local procedure AddLine(var PurchaseHeader: Record "Purchase Header"; Amount: Decimal)
    var
        UnitCost: Decimal;
    begin
        // Precision is read here, but the setup is not loaded on the LCY path.
        UnitCost := Round(-Amount, GeneralLedgerSetup."Unit-Amount Rounding Precision"); // Round(x, 0) -> runtime error

        if PurchaseHeader."Currency Code" <> '' then begin
            GetGLSetup(); // too late, and only for FCY
            UnitCost := Round(UnitCost, GeneralLedgerSetup."Unit-Amount Rounding Precision");
        end;
    end;

    local procedure GetGLSetup()
    begin
        if GLSetupRead then
            exit;
        GeneralLedgerSetup.Get();
        GLSetupRead := true;
    end;
}
