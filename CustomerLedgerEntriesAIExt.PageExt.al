namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Receivables;

pageextension 50104 CustomerLedgerEntriesAIExt extends "Customer Ledger Entries"
{
    actions
    {
        addlast(processing)
        {
            group(AICollectionGroup)
            {
                Caption = 'AI Collections';
                Image = Sparkle;

                action(AICollectionDrafter)
                {
                    Caption = 'AI Collection Drafter';
                    ToolTip = 'Open the AI Collection Assistant to draft context-aware overdue payment reminders and follow-up notices with 1-click email dispatch.';
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
                        CollectionAssistantPage.SetFromCustLedgerEntry(Rec);
                        CollectionAssistantPage.RunModal();
                    end;
                }
            }
        }
    }
}
