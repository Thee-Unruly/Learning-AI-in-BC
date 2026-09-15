namespace DefaultPublisher.ALProject1;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 50107 ChartOfAccountsAIExt extends "Chart of Accounts"
{
    actions
    {
        addlast(processing)
        {
            group(AIFinancialExplainerGroup)
            {
                Caption = 'AI Financial Intelligence';
                Image = Sparkle;

                action(OpenAIFinancialExplainer)
                {
                    Caption = 'AI Financial Variance Explainer';
                    ToolTip = 'Analyze G/L net changes, revenue trends, expense variances, and working capital with AI.';
                    ApplicationArea = All;
                    Image = Sparkle;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        FinancialCommentaryPage: Page "AI Financial Commentary";
                    begin
                        FinancialCommentaryPage.Run();
                    end;
                }
            }
        }
    }
}
