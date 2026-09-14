controladdin "AI Chat Bot Control"
{
    Scripts = 'AIChatBot/scripts/chatbot.js';
    StyleSheets = 'AIChatBot/styles/chatbot.css';
    StartupScript = 'AIChatBot/scripts/startup.js';
    HorizontalStretch = true;
    VerticalStretch = true;
    RequestedHeight = 1;
    RequestedWidth = 1;
    MinimumHeight = 0;
    MinimumWidth = 0;

    event ControlReady();
    event AskQuestion(Question: Text);

    procedure ReceiveAnswer(Answer: Text);
    procedure ReceiveError(ErrorMessage: Text);
}
