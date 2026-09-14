namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Customer;

codeunit 50100 "AI Management"
{
    Access = Public;

    procedure AskAI(UserPrompt: Text): Text
    var
        AISetup: Record "AI Setup";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        PayloadJson: JsonObject;
        MessagesArray: JsonArray;
        SystemMessageJson: JsonObject;
        UserMessageJson: JsonObject;
        ResponseJson: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        ResultToken: JsonToken;
        AnswerText: Text;
    begin
        AISetup.GetSetup();

        if AISetup."API Endpoint" = '' then
            Error('Please configure the API Endpoint in the AI Setup page.');

        // Executive, natural human tone without cheesy emoji overload
        SystemMessageJson.Add('role', 'system');
        SystemMessageJson.Add('content', 'You are an executive enterprise assistant in Microsoft Dynamics 365 Business Central. Write in a sophisticated, clear, and natural human business tone. Avoid emojis, buzzwords, or markdown symbols like asterisks (** or *). Be concise, insightful, and practical.');
        MessagesArray.Add(SystemMessageJson);

        UserMessageJson.Add('role', 'user');
        UserMessageJson.Add('content', UserPrompt);
        MessagesArray.Add(UserMessageJson);

        PayloadJson.Add('model', AISetup."Model Name");
        PayloadJson.Add('messages', MessagesArray);
        PayloadJson.Add('temperature', 0.6);

        PayloadJson.WriteTo(PayloadText);

        // Prepare HTTP Request
        RequestContent.WriteFrom(PayloadText);
        RequestContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(AISetup."API Endpoint");
        RequestMessage.Content(RequestContent);

        RequestMessage.GetHeaders(RequestHeaders);
        if AISetup."API Key" <> '' then
            RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', AISetup."API Key"));

        // 20-second timeout to prevent indefinite hanging
        Client.Timeout(20000);

        // Send HTTP Request
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error('Could not connect to AI API endpoint: %1\\Ensure that the network is reachable and "Allow HttpClient Requests" is enabled for this extension under Extension Management in Business Central.', AISetup."API Endpoint");

        ResponseMessage.Content.ReadAs(ResponseText);

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('AI API Error (HTTP %1):\n%2', ResponseMessage.HttpStatusCode(), ResponseText);

        // Parse OpenAI-compatible response JSON (choices[0].message.content)
        if ResponseJson.ReadFrom(ResponseText) then begin
            if ResponseJson.SelectToken('choices[0].message.content', ResultToken) then
                AnswerText := ResultToken.AsValue().AsText()
            else
                AnswerText := ResponseText;
        end else
            AnswerText := ResponseText;

        AnswerText := CleanFormatting(AnswerText);

        exit(AnswerText);
    end;

    procedure GenerateCustomerEmail(Cust: Record Customer; EmailObjective: Text; AdditionalNotes: Text; var EmailSubject: Text; var EmailBody: Text)
    var
        Prompt: Text;
        RawResponse: Text;
        SubjectPos: Integer;
        BodyPos: Integer;
        RecipientName: Text;
    begin
        Cust.CalcFields("Balance (LCY)", "Sales (LCY)");

        RecipientName := Cust.Contact;
        if RecipientName = '' then
            RecipientName := Cust.Name;

        Prompt := StrSubstNo(
            'Write a polished business outreach email to this customer based on our ERP account history:\' +
            'Customer Name: %1\' +
            'Contact Person: %2\' +
            'Email: %3\' +
            'Current Outstanding Balance: %4 LCY\' +
            'Lifetime Sales Volume: %5 LCY\' +
            'Payment Terms: %6\' +
            'Primary Email Goal: %7\' +
            'Account Manager Notes: %8\\' +
            'Guidelines:\' +
            '- Write as a senior business relationship manager.\' +
            '- Tone: Genuine, respectful, tailored to their relationship status, and human. Do NOT sound like an AI.\' +
            '- Reference context intelligently (e.g. if sales is zero or dormant, focus on re-introducing value and exploring synergies; if balance is active, be constructive and collaborative).\' +
            '- Provide the output with exact markers:\' +
            'SUBJECT: <Subject Line>\' +
            'BODY:\' +
            '<Full Email Body with proper greeting and sign-off placeholder>',
            Cust.Name,
            RecipientName,
            Cust."E-Mail",
            Cust."Balance (LCY)",
            Cust."Sales (LCY)",
            Cust."Payment Terms Code",
            EmailObjective,
            AdditionalNotes
        );

        RawResponse := AskAI(Prompt);

        SubjectPos := StrPos(RawResponse, 'SUBJECT:');
        BodyPos := StrPos(RawResponse, 'BODY:');

        if (SubjectPos > 0) and (BodyPos > SubjectPos) then begin
            EmailSubject := CopyStr(RawResponse, SubjectPos + 8, BodyPos - (SubjectPos + 8));
            EmailSubject := EmailSubject.Trim();
            EmailBody := CopyStr(RawResponse, BodyPos + 5);
            EmailBody := EmailBody.Trim();
        end else begin
            EmailSubject := StrSubstNo('Partnership & Account Discussion: %1', Cust.Name);
            EmailBody := RawResponse;
        end;
    end;

    local procedure CleanFormatting(InputText: Text): Text
    var
        Cleaned: Text;
    begin
        Cleaned := InputText.Replace('**', '');
        Cleaned := Cleaned.Replace('### ', '');
        Cleaned := Cleaned.Replace('## ', '');
        Cleaned := Cleaned.Replace('# ', '');
        exit(Cleaned);
    end;

    [TryFunction]
    procedure TryAskAI(UserPrompt: Text; var AnswerText: Text)
    begin
        AnswerText := AskAI(UserPrompt);
    end;

    [TryFunction]
    procedure TryGenerateCustomerEmail(Cust: Record Customer; EmailObjective: Text; AdditionalNotes: Text; var EmailSubject: Text; var EmailBody: Text)
    begin
        GenerateCustomerEmail(Cust, EmailObjective, AdditionalNotes, EmailSubject, EmailBody);
    end;
}
