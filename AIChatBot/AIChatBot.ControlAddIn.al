controladdin "AI Chat Bot Control"
{
    Scripts = 'AIChatBot/scripts/chatbot.js';
    StyleSheets = 'AIChatBot/styles/chatbot.css';
    StartupScript = 'AIChatBot/scripts/startup.js';
    HorizontalStretch = false;
    VerticalStretch = false;
    VerticalShrink = true;
    HorizontalShrink = true;
    RequestedHeight = 1;
    MinimumHeight = 0;
    RequestedWidth = 1;
    MinimumWidth = 0;

    event ControlReady();
    event AskQuestion(Question: Text);

    procedure ReceiveAnswer(Answer: Text);
    procedure ReceiveError(ErrorMessage: Text);
}
