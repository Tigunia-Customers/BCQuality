// GOOD: when configured security filters are not in scope, isolate at the application
// layer — explicitly filter the source to the current user's salesperson — rather than
// implying isolation a page property does not enforce.
page 50101 "Good Rep Commission List"
{
    PageType = List;
    SourceTable = "Commission Ledger Entry";
    Editable = false;

    layout { area(Content) { repeater(Lines) { field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; } } } }

    trigger OnOpenPage()
    var
        OwnSalespersonCode: Code[20];
    begin
        // Resolve the current user's salesperson (omitted) and scope the source explicitly.
        OwnSalespersonCode := CurrentUserSalespersonCode();
        if OwnSalespersonCode <> '' then
            Rec.SetRange("Salesperson Code", OwnSalespersonCode);
        // For enforced row security (not just a UI filter), configure security filters on the
        // user's permission sets; SecurityFiltering then controls how strictly they apply.
    end;

    local procedure CurrentUserSalespersonCode(): Code[20]
    begin
        exit(''); // resolve from the user-setup / salesperson mapping
    end;
}
