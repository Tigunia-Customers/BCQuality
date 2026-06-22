// BAD: OnInsert scans the live table, which does NOT include the in-flight Rec.
// The split total is computed without the row being inserted, so an invalid set
// can commit (or a valid completing row be rejected).
table 50100 "Bad Split Line"
{
    fields { field(1; "Scope"; Code[20]) { } field(2; "Line No."; Integer) { } field(3; "Split %"; Decimal) { } }
    keys { key(PK; "Scope", "Line No.") { } }

    trigger OnInsert()
    var
        Sibling: Record "Bad Split Line";
        Total: Decimal;
    begin
        Sibling.SetRange("Scope", Rec."Scope");
        Sibling.CalcSums("Split %"); // the live table does not yet contain Rec
        Total := Sibling."Split %";
        if Total <> 100 then
            Error('Splits must total 100%%.'); // wrong: Rec's own % is missing from Total
    end;
}
