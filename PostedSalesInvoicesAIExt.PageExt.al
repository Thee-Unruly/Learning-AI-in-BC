namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.History;

pageextension 50106 PostedSalesInvoicesAIExt extends "Posted Sales Invoices"
{
    actions
    {
        addlast(processing)
        {
            group(AIInvoiceListGroup)
            {
                Caption = 'AI Follow-Up';
                Image = Sparkle;

                action(AIFollowUpListDrafter)
                {
                    Caption = 'AI Invoice Follow-Up';
                    ToolTip = 'Draft an intelligent payment reminder or client follow-up email for the selected posted sales invoice.';
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
