// BAD: the Post-Batch codeunit raises the outcome Message itself, "guarded" by GuiAllowed().
// GuiAllowed() is TRUE in the BC test runner, so the Message still fires during automated
// tests and aborts them with "Unhandled UI: Message". The guard does nothing useful and
// hides that this codeunit is also called by the engine inside a posting transaction.
codeunit 50100 "Bad Comm. Jnl.-Post Batch"
{
    TableNo = "Commission Journal Line";

    trigger OnRun()
    begin
        PostBatch(Rec);
    end;

    var
        PostedMsg: Label '%1 line(s) were posted.', Comment = '%1 = posted count';

    procedure PostBatch(var JournalLine: Record "Commission Journal Line")
    var
        PostedCount: Integer;
    begin
        // ... validate + post each line, incrementing PostedCount ...

        ReportOutcome(PostedCount);
    end;

    local procedure ReportOutcome(PostedCount: Integer)
    begin
        if not GuiAllowed() then
            exit; // useless in tests: GuiAllowed() is true, so the Message below still fires
        Message(PostedMsg, PostedCount);
    end;
}
