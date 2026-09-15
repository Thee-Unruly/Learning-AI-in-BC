namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.History;

pageextension 50105 PostedSalesInvoiceAIExt extends "Posted Sales Invoice"
{
    actions
    {
        addlast(processing)
        {
            group(AIInvoiceGroup)
            {
                Caption = 'AI Follow-Up';
                Image = Sparkle;

                action(AIFollowUpDrafter)
                {
                    Caption = 'AI Invoice Follow-Up';
                    ToolTip = 'Draft an intelligent payment reminder or client follow-up email incorporating specific line items and payment terms.';
                    ApplicationArea = All;
                    Image = Sparkle;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        CollectionAssistantPage: Page "AI Collection Assistant";
                    begin
                        CollectionAssistantPage.SetFromSalesInvoiceHeader(Rec);
                        CollectionAssistantPage.RunModal();
                    end;
                }
            }
        }
    }
}
