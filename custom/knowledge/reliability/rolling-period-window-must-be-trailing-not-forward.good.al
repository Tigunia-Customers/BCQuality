// GOOD: the duration is applied BACKWARD to build a trailing window ending on the anchor,
// so [Start, Anchor] is a valid range that accumulates the period's prior entries. The
// window math lives in one shared helper so every caller uses the same correct computation.
codeunit 50101 "Good Rolling Window Example"
{
    procedure ConsumedInPeriod(SalespersonCode: Code[20]; CapPeriod: DateFormula; AnchorDate: Date): Decimal
    var
        LedgerEntry: Record "Commission Ledger Entry";
        PeriodStart: Date;
    begin
        PeriodStart := TrailingPeriodStart(CapPeriod, AnchorDate);

        LedgerEntry.SetRange("Salesperson Code", SalespersonCode);
        LedgerEntry.SetRange("Posting Date", PeriodStart, AnchorDate);
        LedgerEntry.CalcSums("Net Payable Amount");
        exit(LedgerEntry."Net Payable Amount");
    end;

    // Negate the duration -> trailing window, inclusive start. A positive '1M' and an
    // explicit '-1M' both yield the same trailing month ending on AnchorDate.
    procedure TrailingPeriodStart(CapPeriod: DateFormula; AnchorDate: Date): Date
    var
        Negated: DateFormula;
        FormulaText: Text;
    begin
        FormulaText := Format(CapPeriod);
        if FormulaText[1] = '-' then
            Negated := CapPeriod
        else
            Evaluate(Negated, '-' + FormulaText);
        exit(CalcDate('<1D>', CalcDate(Negated, AnchorDate)));
    end;
}
