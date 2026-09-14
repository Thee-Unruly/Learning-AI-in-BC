namespace DefaultPublisher.ALProject1;

page 50104 "Amira AI Assistant"
{
    PageType = Card;
    Caption = 'Amira - ERP Assistant';
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            usercontrol(AmiraControl; "AI Chat Bot Control")
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                end;

                trigger AskQuestion(Question: Text)
                var
                    AIMgmt: Codeunit "AI Management";
                    Answer: Text;
                begin
                    if AIMgmt.TryAskERPGuide(Question, Answer) then
                        CurrPage.AmiraControl.ReceiveAnswer(Answer)
                    else
                        CurrPage.AmiraControl.ReceiveError(GetLastErrorText());
                end;
            }
        }
    }
}
