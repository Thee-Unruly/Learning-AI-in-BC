namespace DefaultPublisher.ALProject1;

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

        // Build OpenAI-compatible chat completion payload
        SystemMessageJson.Add('role', 'system');
        SystemMessageJson.Add('content', 'You are an AI assistant embedded directly inside Microsoft Dynamics 365 Business Central. Provide concise, clear, and business-oriented answers.');
        MessagesArray.Add(SystemMessageJson);

        UserMessageJson.Add('role', 'user');
        UserMessageJson.Add('content', UserPrompt);
        MessagesArray.Add(UserMessageJson);

        PayloadJson.Add('model', AISetup."Model Name");
        PayloadJson.Add('messages', MessagesArray);
        PayloadJson.Add('temperature', 0.7);

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

        // Send HTTP Request
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error('Could not connect to AI API endpoint: %1\n\nEnsure that "Allow HttpClient Requests" is enabled for this extension under Extension Management in Business Central.', AISetup."API Endpoint");

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

        exit(AnswerText);
    end;
}
