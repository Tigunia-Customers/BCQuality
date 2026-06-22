// BAD: matches the credit memo to its shipment via "Order No.", which is BLANK on a
// return-order-sourced credit memo. The loop finds no lines, so the source shipment's
// commission is never reversed.
codeunit 50100 "Bad Return Match Example"
{
    procedure ReverseShipmentCommission(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SetFilter("Order No.", '<>%1', ''); // empty on a return-order credit memo -> no rows
        if SalesCrMemoLine.FindSet() then
            repeat
                SalesShipmentLine.SetRange("Order No.", SalesCrMemoLine."Order No.");
                SalesShipmentLine.SetRange("Order Line No.", SalesCrMemoLine."Order Line No.");
                // ... reverse the shipment commission (never reached)
            until SalesCrMemoLine.Next() = 0;
    end;
}
