namespace DefaultPublisher.ALProject1;

using Microsoft.Finance.RoleCenters;

pageextension 50102 BusinessManagerRoleCenterAIExt extends "Business Manager Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(AIChatBotWidget; "AI Chat Bot CardPart")
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
        }
    }
}
