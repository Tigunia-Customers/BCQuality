// BAD: RunWithCheck and PostJnlLine are declared : Boolean but never assign a
// return value, so both always return false. The batch driver below treats every
// successfully posted line as a failure (if not RunWithCheck => after-failure path).
codeunit 50102 "Bad Return Value Example"
{
    procedure RunWithCheck(var JournalLine: Record "Gen. Journal Line"): Boolean
    begin
        CheckLine(JournalLine);
        PostJnlLine(JournalLine);
        // falls off the end -> returns Boolean default (false)
    end;

    local procedure PostJnlLine(var JournalLine: Record "Gen. Journal Line"): Boolean
    begin
        JournalLine.Modify();
        // no exit(true) -> returns false even though the line posted
    end;

    local procedure CheckLine(var JournalLine: Record "Gen. Journal Line")
    begin
    end;

    local procedure PostBatch(var JournalLine: Record "Gen. Journal Line")
    begin
        if JournalLine.FindSet() then
            repeat
                // Polarity is inverted: this runs on EVERY line because RunWithCheck is always false.
                if not RunWithCheck(JournalLine) then
                    OnAfterPostLine(JournalLine);
            until JournalLine.Next() = 0;
    end;

    local procedure OnAfterPostLine(var JournalLine: Record "Gen. Journal Line")
    begin
    end;
}
