namespace DefaultPublisher.ALProject1;

using Microsoft.Finance.RoleCenters;

pageextension 50102 BusinessManagerRoleCenterAIExt extends "Business Manager Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part(AIChatBotWidget; "AI Chat Bot CardPart")
            {
                ApplicationArea = All;
                Caption = 'AI Guide';
            }
        }
    }
}
