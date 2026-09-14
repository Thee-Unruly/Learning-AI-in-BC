namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Customer;

pageextension 50100 CustomerListAIExt extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            group(AIActions)
            {
                Caption = 'AI Insights';
                Image = Sparkle;

                action(AskAIAboutCustomer)
                {
                    Caption = 'Analyze with AI';
                    ToolTip = 'Send customer details and financial balances to external AI for an executive summary.';
                    ApplicationArea = All;
                    Image = Sparkle;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        AIMgmt: Codeunit "AI Management";
                        Prompt: Text;
                        AIResponse: Text;
                    begin
                        Rec.CalcFields("Balance (LCY)", "Sales (LCY)");
                        Prompt := StrSubstNo(
                            'Analyze this customer in Microsoft Dynamics 365 Business Central:\' +
                            'Customer: %1 (%2)\' +
                            'Balance: %3 LCY\' +
                            'Sales: %4 LCY\' +
                            'Credit Limit: %5 LCY\' +
                            'Payment Terms: %6\\' +
                            'Provide exactly two sections without markdown asterisks:\' +
                            '• Account Health: (1 concise sentence)\' +
                            '• Next Action: (1 actionable sentence)',
                            Rec.Name,
                            Rec."No.",
                            Rec."Balance (LCY)",
                            Rec."Sales (LCY)",
                            Rec."Credit Limit (LCY)",
                            Rec."Payment Terms Code"
                        );

                        AIResponse := AIMgmt.AskAI(Prompt);
                        Message('🤖 AI Insights: %1\\%2', Rec.Name, AIResponse);
                    end;
                }
            }
        }
    }
}
