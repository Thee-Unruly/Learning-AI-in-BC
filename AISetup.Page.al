namespace DefaultPublisher.ALProject1;

page 50100 "AI Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "AI Setup";
    Caption = 'AI Integration Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'AI Configuration';

                field("API Endpoint"; Rec."API Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'The REST API endpoint URL (e.g., https://api.groq.com/openai/v1/chat/completions).';
                }
                field("Model Name"; Rec."Model Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The model identifier (e.g., llama-3.3-70b-versatile, llama-3.1-8b-instant, mixtral-8x7b-32768).';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Your Groq API Key (starts with gsk_...). It is masked for security.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test AI Connection';
                ToolTip = 'Sends a quick test prompt to the configured AI API and displays the response directly in Business Central.';
                ApplicationArea = All;
                Image = Sparkle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    AIMgmt: Codeunit "AI Management";
                    Response: Text;
                begin
                    CurrPage.SaveRecord();
                    Response := AIMgmt.AskAI('Hello! In 1 short sentence, confirm you are connected to Microsoft Dynamics 365 Business Central.');
                    Message('🤖 AI Connection Test Successful!\n\nResponse:\n%1', Response);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
