// BAD: after a ship-only post the order is Released; validating "Unit Price" runs
// TestStatusOpen and errors ("Status must be equal to 'Open' ... Current value is 'Released'").
codeunit 50100 "Bad Reopen Example"
{
    procedure RepriceAfterShip(var SalesHeader: Record "Sales Header"; NewUnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.PostSalesDocument(SalesHeader, true, false); // ship only -> order stays Released

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate("Unit Price", NewUnitPrice); // TestStatusOpen -> runtime error on a Released doc
        SalesLine.Modify(true);
    end;
}
