// GOOD: reopen the Released order before validating a TestStatusOpen-guarded field;
// the next post re-releases it. ("Qty. to Ship"/"Qty. to Invoice" would NOT need this.)
codeunit 50101 "Good Reopen Example"
{
    procedure RepriceAfterShip(var SalesHeader: Record "Sales Header"; NewUnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.PostSalesDocument(SalesHeader, true, false); // ship only -> order Released

        LibrarySales.ReopenSalesDocument(SalesHeader); // back to Open so the price can change

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate("Unit Price", NewUnitPrice); // OK: document is Open
        SalesLine.Modify(true);

        LibrarySales.PostSalesDocument(SalesHeader, false, true); // invoicing re-releases then posts
    end;
}
