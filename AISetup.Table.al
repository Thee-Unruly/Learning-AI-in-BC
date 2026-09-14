namespace DefaultPublisher.ALProject1;

table 50100 "AI Setup"
{
    Caption = 'AI Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "API Endpoint"; Text[250])
        {
            Caption = 'API Endpoint';
            DataClassification = CustomerContent;
        }
        field(3; "Model Name"; Text[100])
        {
            Caption = 'Model Name';
            DataClassification = CustomerContent;
        }
        field(4; "API Key"; Text[250])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            "Primary Key" := '';
            "API Endpoint" := 'https://api.groq.com/openai/v1/chat/completions';
            "Model Name" := 'gpt-oss-120b';
            Insert();
        end;
    end;
}
