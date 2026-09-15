namespace DefaultPublisher.ALProject1;

using Microsoft.Finance.RoleCenters;

pageextension 50102 BusinessManagerRoleCenterAIExt extends "Business Manager Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part(AIChatBotWidget; "AI Chat Bot CardPart")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addfirst(embedding)
        {
            action(NavFinancialCommentary)
            {
                Caption = 'AI Financial Commentary';
                ToolTip = 'Generate a 1-page executive financial commentary and cash flow analysis comparing current performance against the prior period.';
                ApplicationArea = All;
                Image = Sparkle;
                RunObject = Page "AI Financial Commentary";
            }
        }
        addlast(creation)
        {
            action(ActionFinancialCommentary)
            {
                Caption = 'AI Financial Commentary';
                ToolTip = 'Generate a 1-page executive financial commentary and cash flow analysis comparing current performance against the prior period.';
                ApplicationArea = All;
                Image = Sparkle;
                RunObject = Page "AI Financial Commentary";
            }
        }
        addlast(processing)
        {
            group(AIFinanceIntelligenceGroup)
            {
                Caption = 'AI Financial Intelligence';
                Image = Sparkle;

                action(OpenAIFinancialCommentary)
                {
                    Caption = 'AI Financial & Cash Flow Commentary';
                    ToolTip = 'Generate a 1-page executive financial commentary and cash flow analysis comparing current performance against the prior period.';
                    ApplicationArea = All;
                    Image = Sparkle;
                    RunObject = Page "AI Financial Commentary";
                }
            }
        }
    }
}
