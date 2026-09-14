namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Customer;

pageextension 50101 CustomerCardAIExt extends "Customer Card"
{
    actions
    {
        addlast(processing)
        {
            group(AICustomerCardGroup)
            {
                Caption = 'AI Insights';
                Image = Sparkle;

                action(AskAIOnCard)
                {
                    Caption = 'Analyze with AI';
                    ToolTip = 'Send customer financial metrics to external AI for instant executive summary and risk assessment.';
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
                            'Analyze this customer from Business Central:\' +
                            '- Customer No: %1\' +
                            '- Customer Name: %2\' +
                            '- Balance (LCY): %3\' +
                            '- Total Sales (LCY): %4\' +
                            '- Credit Limit (LCY): %5\' +
                            '- Payment Terms: %6\\' +
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
