// GOOD: every insert/modify/delete re-validates the WHOLE ordered band set for
// contiguity: first band at 0, each From = the prior To (no gap, no overlap), only the
// last band open-ended. (Build the post-change set with the stage-siblings/overlay-Rec
// pattern so the in-flight or being-deleted row is reflected.)
table 50101 "Good Tier Band"
{
    fields
    {
        field(1; "Plan Code"; Code[20]) { }
        field(2; "From Amount"; Decimal) { }
        field(3; "To Amount"; Decimal) { }
        field(4; "Rate %"; Decimal) { }
    }
    keys { key(PK; "Plan Code", "From Amount") { } }

    trigger OnInsert() begin ValidateContiguity(Rec."Plan Code"); end;

    trigger OnModify() begin ValidateContiguity(Rec."Plan Code"); end;

    trigger OnDelete() begin ValidateContiguityAfterDelete(Rec); end;

    local procedure ValidateContiguity(PlanCode: Code[20])
    var
        Band: Record "Good Tier Band"; // in practice: the staged post-change set (siblings + overlaid Rec)
        ExpectedFrom: Decimal;
        IsFirst: Boolean;
    begin
        Band.SetRange("Plan Code", PlanCode);
        Band.SetCurrentKey("Plan Code", "From Amount");
        IsFirst := true;
        if Band.FindSet() then
            repeat
                if IsFirst then begin
                    if Band."From Amount" <> 0 then
                        Error('The first band must start at 0.');
                    IsFirst := false;
                end else
                    if Band."From Amount" <> ExpectedFrom then
                        Error('Bands must be contiguous: no gaps or overlaps.');
                ExpectedFrom := Band."To Amount"; // next band must start where this one ends
            until Band.Next() = 0;
    end;

    local procedure ValidateContiguityAfterDelete(var DeletedBand: Record "Good Tier Band")
    begin
        // Re-validate the set with DeletedBand removed so an interior delete that opens a gap is rejected.
        ValidateContiguity(DeletedBand."Plan Code");
    end;
}
