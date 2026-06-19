// GOOD: the margin calc is pure and consumes the line's COGS supplied by the caller. The posting
// trigger that owns the source document (and its value entries / posting buffer) knows the exact
// COGS for the quantity sold and passes it in. The calc does no item-ledger lookup of its own —
// it cannot, lacking the document identity — and rejects a margin request with no supplied cost
// rather than falling back to a cumulative or zero cost.
codeunit 50101 "Good Margin Calc"
{
    procedure CalculateMargin(CostKnown: Boolean; LineCOGS: Decimal; SalesAmount: Decimal; RatePct: Decimal): Decimal
    begin
        if not CostKnown then
            Error(MarginCostRequiredErr); // contract error — caller (posting trigger) must supply the COGS
        exit((SalesAmount - LineCOGS) * RatePct / 100);
    end;

    var
        MarginCostRequiredErr: Label 'The posted cost (COGS) must be supplied for a margin calculation.';
}

// The posting trigger that holds the source document sources the line's COGS and supplies it.
codeunit 50102 "Good Margin Posting Trigger"
{
    procedure PostLineCommission(SalesShptLine: Record "Sales Shipment Line"; RatePct: Decimal): Decimal
    var
        MarginCalc: Codeunit "Good Margin Calc";
        ValueEntry: Record "Value Entry";
        LineCOGS: Decimal;
    begin
        // COGS scoped to THIS shipment line's value entries (document + line), not the whole item.
        ValueEntry.SetRange("Document No.", SalesShptLine."Document No.");
        ValueEntry.SetRange("Document Line No.", SalesShptLine."Line No.");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        LineCOGS := -ValueEntry."Cost Amount (Actual)"; // outbound COGS is negative in the ledger

        exit(MarginCalc.CalculateMargin(true, LineCOGS, SalesShptLine."Amount", RatePct));
    end;
}
