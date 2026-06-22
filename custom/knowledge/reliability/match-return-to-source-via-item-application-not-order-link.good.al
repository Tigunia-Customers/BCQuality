// GOOD: resolves the source shipment through the item application that survives a
// return-of-goods flow: the credit-memo line's "Appl.-from Item Entry" is the shipment's
// outbound Item Ledger Entry, whose "Document No." is the posted shipment.
codeunit 50101 "Good Return Match Example"
{
    procedure ReverseShipmentCommission(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SetFilter("Appl.-from Item Entry", '<>%1', 0);
        if SalesCrMemoLine.FindSet() then
            repeat
                if ItemLedgerEntry.Get(SalesCrMemoLine."Appl.-from Item Entry") then
                    if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then
                        ; // reverse the commission sourced to ItemLedgerEntry."Document No." (the posted shipment)
            until SalesCrMemoLine.Next() = 0;
    end;
}
