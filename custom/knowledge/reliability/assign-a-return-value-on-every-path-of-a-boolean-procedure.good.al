// GOOD: PostJnlLine returns true on success, RunWithCheck propagates it, and the
// batch driver fires the after-post hook under the correct (positive) polarity.
codeunit 50103 "Good Return Value Example"
{
    procedure RunWithCheck(var JournalLine: Record "Gen. Journal Line"): Boolean
    begin
        CheckLine(JournalLine);
        exit(PostJnlLine(JournalLine)); // propagate the result instead of falling through
    end;

    local procedure PostJnlLine(var JournalLine: Record "Gen. Journal Line"): Boolean
    begin
        JournalLine.Modify();
        exit(true); // success path explicitly returns true
    end;

    local procedure CheckLine(var JournalLine: Record "Gen. Journal Line")
    begin
    end;

    local procedure PostBatch(var JournalLine: Record "Gen. Journal Line")
    begin
        if JournalLine.FindSet() then
            repeat
                // Correct polarity: the after-post hook runs only on success.
                if RunWithCheck(JournalLine) then
                    OnAfterPostLine(JournalLine);
            until JournalLine.Next() = 0;
    end;

    local procedure OnAfterPostLine(var JournalLine: Record "Gen. Journal Line")
    begin
    end;
}
