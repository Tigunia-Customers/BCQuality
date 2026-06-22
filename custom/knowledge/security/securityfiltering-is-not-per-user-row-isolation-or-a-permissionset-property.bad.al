// BAD: a List page sets SecurityFiltering = Filtered expecting it to limit each rep to
// their own commission rows. With no configured security filters behind it, the property
// has nothing to apply and every user still sees every row.
page 50100 "Bad Rep Commission List"
{
    PageType = List;
    SourceTable = "Commission Ledger Entry";
    SourceTableView = sorting("Entry No.");
    // Intent: "reps see only their own rows." Reality: no security filter is configured,
    // so this isolates nothing; it only governs HOW existing filters (none) would apply.
    // (And SecurityFiltering is not a permissionset property — it cannot live in the role set.)

    layout { area(Content) { repeater(Lines) { field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; } } } }
}
