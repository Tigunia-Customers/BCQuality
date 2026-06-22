// BAD: a positive Cap Period duration applied FORWARD lands the window start in the
// future, so SetRange(Posting Date, Start, AnchorDate) is inverted and matches nothing.
// The period cap then sees zero prior consumption and silently never binds.
codeunit 50100 "Bad Rolling Window Example"
{
    procedure ConsumedInPeriod(SalespersonCode: Code[20]; CapPeriod: DateFormula; AnchorDate: Date): Decimal
    var
        LedgerEntry: Record "Commission Ledger Entry";
        PeriodStart: Date;
    begin
        // CapPeriod is '1M' (a positive duration). CalcDate('1M', AnchorDate) = AnchorDate + 1 month
        // (the FUTURE); stepping back a day is still after AnchorDate.
        PeriodStart := CalcDate('<-1D>', CalcDate(CapPeriod, AnchorDate));

        LedgerEntry.SetRange("Salesperson Code", SalespersonCode);
        LedgerEntry.SetRange("Posting Date", PeriodStart, AnchorDate); // Start > AnchorDate -> empty range
        LedgerEntry.CalcSums("Net Payable Amount");
        exit(LedgerEntry."Net Payable Amount"); // always 0 for a positive period
    end;
}
