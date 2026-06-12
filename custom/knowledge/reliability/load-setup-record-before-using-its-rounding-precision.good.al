// GOOD: the setup is loaded before every read of a precision field.
// GetGLSetup() is idempotent, so calling it before each Round() is free on
// paths that already loaded the setup, and correct on paths that had not.
codeunit 50101 "Good Rounding Example"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

    local procedure AddLine(var PurchaseHeader: Record "Purchase Header"; Amount: Decimal)
    var
        UnitCost: Decimal;
    begin
        GetGLSetup(); // ensure the setup is loaded before reading its precision
        UnitCost := Round(-Amount, GeneralLedgerSetup."Unit-Amount Rounding Precision");

        if PurchaseHeader."Currency Code" <> '' then begin
            GetGLSetup(); // idempotent: returns early, no extra DB read
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
