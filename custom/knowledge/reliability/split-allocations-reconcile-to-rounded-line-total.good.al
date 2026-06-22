// GOOD: round every share but the last independently; the last share absorbs the
// residual so the shares always sum EXACTLY to the rounded line total.
codeunit 50101 "Good Split Example"
{
    procedure AllocateShares(LineTotal: Decimal; var TempShare: Record "Allocation Share" temporary)
    var
        Agent: Record "Allocation Share";
        RoundedTotal: Decimal;
        PriorSum: Decimal;
        Index: Integer;
        AgentCount: Integer;
    begin
        RoundedTotal := Round(LineTotal);
        AgentCount := Agent.Count();
        if Agent.FindSet() then
            repeat
                Index += 1;
                TempShare := Agent;
                if Index < AgentCount then begin
                    TempShare.Amount := Round(LineTotal * Agent."Split %" / 100);
                    PriorSum += TempShare.Amount;
                end else
                    TempShare.Amount := RoundedTotal - PriorSum; // last share = residual; rows now tie out
                TempShare.Insert();
            until Agent.Next() = 0;
    end;
}
