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
                        AIModal: Page "AI Insights Modal";
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
                            'Format your response into these 3 clear sections:\' +
                            '📊 ACCOUNT HEALTH: (1-2 sentences on credit exposure and revenue performance)\' +
                            '⚡ RISK ASSESSMENT: (Low / Medium / High with reason)\' +
                            '💡 RECOMMENDED ACTION: (1-2 actionable next steps for the account manager)',
                            Rec.Name,
                            Rec."No.",
                            Rec."Balance (LCY)",
                            Rec."Sales (LCY)",
                            Rec."Credit Limit (LCY)",
                            Rec."Payment Terms Code"
                        );

                        AIResponse := AIMgmt.AskAI(Prompt);

                        AIModal.SetData(Rec."No.", Rec.Name, Rec."Balance (LCY)", Rec."Credit Limit (LCY)", AIResponse);
                        AIModal.RunModal();
                    end;
                }
            }
        }
    }
}
