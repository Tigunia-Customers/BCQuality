// BAD: when the caller doesn't supply a cost, the margin calc sums the item's value entries
// up to the posting date. CalcSums over "Item No." + "Posting Date" is the item's CUMULATIVE
// cost (every receipt/shipment/adjustment, all documents) — not this line's COGS. It is correct
// only for a single-transaction item, which is exactly what the masking unit test creates. And
// for an on-posting commission the sale's own value entries don't exist yet, so they're missed.
codeunit 50100 "Bad Margin Calc"
{
    procedure CalculateMargin(ItemNo: Code[20]; PostingDate: Date; SalesAmount: Decimal; RatePct: Decimal): Decimal
    var
        Cost: Decimal;
    begin
        Cost := ItemLedgerCostAtPosting(ItemNo, PostingDate); // <-- cumulative item cost, not line COGS
        exit((SalesAmount - Cost) * RatePct / 100);
    end;

    local procedure ItemLedgerCostAtPosting(ItemNo: Code[20]; PostingDate: Date): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item No.", ItemNo);               // filtered by ITEM only...
        ValueEntry.SetRange("Posting Date", 0D, PostingDate);  // ...plus a date ceiling
        ValueEntry.CalcSums("Cost Amount (Actual)");           // sums ALL the item's value entries
        exit(ValueEntry."Cost Amount (Actual)");
    end;
}
