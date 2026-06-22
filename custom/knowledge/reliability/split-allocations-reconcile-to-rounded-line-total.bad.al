// BAD: each share is rounded independently, so on an odd-cent total the shares don't
// sum to the rounded total. $100.01 at 33.33/33.33/33.34 -> 33.34 x 3 = $100.02.
codeunit 50100 "Bad Split Example"
{
    procedure AllocateShares(LineTotal: Decimal; var TempShare: Record "Allocation Share" temporary)
    var
        Agent: Record "Allocation Share";
    begin
        if Agent.FindSet() then
            repeat
                TempShare := Agent;
                TempShare.Amount := Round(LineTotal * Agent."Split %" / 100); // independent rounding
                TempShare.Insert();
            until Agent.Next() = 0;
        // No reconciliation: Sum(TempShare.Amount) may be Round(LineTotal) +/- a cent.
    end;
}
