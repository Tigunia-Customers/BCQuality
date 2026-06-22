// GOOD: stage committed siblings (excluding Rec's own key) into a temp record, overlay
// the in-flight Rec, then validate the temp set — so Rec's in-flight value is counted.
table 50101 "Good Split Line"
{
    fields { field(1; "Scope"; Code[20]) { } field(2; "Line No."; Integer) { } field(3; "Split %"; Decimal) { } }
    keys { key(PK; "Scope", "Line No.") { } }

    trigger OnInsert()
    begin
        ValidateScopeTotal();
    end;

    trigger OnModify()
    begin
        ValidateScopeTotal();
    end;

    local procedure ValidateScopeTotal()
    var
        TempStaged: Record "Good Split Line" temporary;
        Sibling: Record "Good Split Line";
        Total: Decimal;
    begin
        Sibling.SetRange("Scope", Rec."Scope");
        Sibling.SetFilter("Line No.", '<>%1', Rec."Line No."); // committed siblings, excluding Rec's own key
        if Sibling.FindSet() then
            repeat
                TempStaged := Sibling;
                TempStaged.Insert();
            until Sibling.Next() = 0;

        TempStaged := Rec; // overlay the in-flight row
        if not TempStaged.Insert() then
            TempStaged.Modify();

        TempStaged.Reset();
        TempStaged.CalcSums("Split %");
        Total := TempStaged."Split %";
        if Total <> 100 then
            Error('Splits must total 100%%.');
    end;
}
