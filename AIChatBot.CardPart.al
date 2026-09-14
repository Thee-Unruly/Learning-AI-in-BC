namespace DefaultPublisher.ALProject1;

page 50103 "AI Chat Bot CardPart"
{
    PageType = CardPart;
    Caption = ' ';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            usercontrol(ChatBotControl; "AI Chat Bot Control")
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
                        CurrPage.ChatBotControl.ReceiveAnswer(Answer)
                    else
                        CurrPage.ChatBotControl.ReceiveError(GetLastErrorText());
                end;
            }
        }
    }
}
