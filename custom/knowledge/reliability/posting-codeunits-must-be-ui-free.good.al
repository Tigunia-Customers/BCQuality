// GOOD: the Post-Batch codeunit is UI-free — it returns the posted count to the caller and
// raises no Message/Confirm on any path. Tests drive PostBatchLines directly and assert the
// returned count (no handler needed); the engine can post a staged batch inside its own
// posting transaction. The page action owns the user-facing summary, where a UI session
// always exists. (Error/FieldError are still fine inside the codeunit — they are not UI.)
codeunit 50101 "Good Comm. Jnl.-Post Batch"
{
    TableNo = "Commission Journal Line";

    trigger OnRun()
    var
        PostedCount: Integer;
    begin
        PostBatchLines(Rec, PostedCount);
    end;

    procedure PostBatchLines(var JournalLine: Record "Commission Journal Line"; var PostedCount: Integer)
    begin
        PostedCount := 0;
        // ... validate + post each line, incrementing PostedCount ...
        // No Message/Confirm here — the outcome is returned through PostedCount.
    end;
}

// The page action presents the outcome — a page always runs in a UI session.
page 50102 "Good Commission Journal"
{
    PageType = Worksheet;
    SourceTable = "Commission Journal Line";

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Post';

                trigger OnAction()
                var
                    PostBatch: Codeunit "Good Comm. Jnl.-Post Batch";
                    PostedCount: Integer;
                begin
                    PostBatch.PostBatchLines(Rec, PostedCount);
                    CurrPage.Update(false);
                    Message(PostedMsg, PostedCount);
                end;
            }
        }
    }

    var
        PostedMsg: Label '%1 line(s) were posted.', Comment = '%1 = posted count';
}
