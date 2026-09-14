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

                action(OpenAIAssistantList)
                {
                    Caption = 'AI Executive Assistant';
                    ToolTip = 'Open the AI Executive Assistant to evaluate account health, review risk metrics, and generate tailored outreach emails.';
                    ApplicationArea = All;
                    Image = Sparkle;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        AIAssistantPage: Page "AI Customer Assistant";
                    begin
                        AIAssistantPage.SetCustomer(Rec."No.");
                        AIAssistantPage.RunModal();
                    end;
                }
            }
        }
    }
}
