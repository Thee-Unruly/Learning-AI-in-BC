namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Customer;

pageextension 50100 CustomerListAIExt extends "Customer List"
{
    actions
    {
        addafter("&Customer")
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

                    trigger OnAction()
                    var
                        AIMgmt: Codeunit "AI Management";
                        Prompt: Text;
                        AIResponse: Text;
                    begin
                        Rec.CalcFields("Balance (LCY)", "Sales (LCY)");
                        Prompt := StrSubstNo(
                            'Analyze this customer from Business Central:\n' +
                            '- Customer No: %1\n' +
                            '- Customer Name: %2\n' +
                            '- Balance (LCY): %3\n' +
                            '- Total Sales (LCY): %4\n' +
                            '- Credit Limit (LCY): %5\n' +
                            '- Payment Terms: %6\n\n' +
                            'Provide a 2-bullet executive summary: 1) Account Health, 2) Recommended Next Action.',
                            Rec."No.",
                            Rec.Name,
                            Rec."Balance (LCY)",
                            Rec."Sales (LCY)",
                            Rec."Credit Limit (LCY)",
                            Rec."Payment Terms Code"
                        );

                        AIResponse := AIMgmt.AskAI(Prompt);
                        Message('🤖 AI Insights for %1:\\%2', Rec.Name, AIResponse);
                    end;
                }
            }
        }
    }
}
