controladdin "AI Chat Bot Control"
{
    Scripts = 'AIChatBot/scripts/chatbot.js';
    StyleSheets = 'AIChatBot/styles/chatbot.css';
    StartupScript = 'AIChatBot/scripts/startup.js';
    HorizontalStretch = true;
    VerticalStretch = true;
    VerticalShrink = false;
    HorizontalShrink = false;
    RequestedHeight = 720;
    MinimumHeight = 650;
    RequestedWidth = 460;
    MinimumWidth = 420;

    event ControlReady();
    event AskQuestion(Question: Text);

    procedure ReceiveAnswer(Answer: Text);
    procedure ReceiveError(ErrorMessage: Text);
}
