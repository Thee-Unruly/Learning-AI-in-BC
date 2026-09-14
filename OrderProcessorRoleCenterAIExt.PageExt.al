namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.RoleCenters;

pageextension 50103 OrderProcessorRoleCenterAIExt extends "Order Processor Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part(AIChatBotWidget; "AI Chat Bot CardPart")
            {
                ApplicationArea = All;
                Caption = 'Amira';
            }
        }
    }
}
