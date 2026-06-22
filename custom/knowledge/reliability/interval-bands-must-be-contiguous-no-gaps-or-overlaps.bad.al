// BAD: only the changed row is validated (From < To), and there is NO OnDelete check.
// Deleting an interior band opens a gap that nothing rejects; amounts in that range
// then fall through to the wrong tier at calculation time.
table 50100 "Bad Tier Band"
{
    fields
    {
        field(1; "Plan Code"; Code[20]) { }
        field(2; "From Amount"; Decimal) { }
        field(3; "To Amount"; Decimal) { }
        field(4; "Rate %"; Decimal) { }
    }
    keys { key(PK; "Plan Code", "From Amount") { } }

    trigger OnInsert()
    begin
        if (Rec."To Amount" <> 0) and (Rec."To Amount" <= Rec."From Amount") then
            Error('To must exceed From.'); // per-row only: ignores gaps/overlaps across the set
    end;

    // No OnModify / OnDelete contiguity check -> a deleted interior band silently opens a gap.
}
