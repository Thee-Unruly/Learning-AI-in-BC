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

    procedure AskERPGuide(UserQuestion: Text): Text
    var
        Prompt: Text;
        Answer: Text;
        AISetup: Record "AI Setup";
    begin
        AISetup.GetSetup();

        // If API Key is configured, use live LLM
        if (AISetup."API Key" <> '') and (AISetup."API Endpoint" <> '') then begin
            Prompt := StrSubstNo(
                'You are Amira, a knowledgeable, friendly, and expert ERP Onboarding & System Guide AI for Microsoft Dynamics 365 Business Central.\' +
                'Introduce yourself as Amira when asked. Provide clear, concise, and step-by-step instructions for the user.\' +
                'Core System Knowledge:\' +
                '- Global Search: Press Alt+Q (Tell Me) to search for any page, report, or task in Business Central.\' +
                '- Sales Invoices / Orders: Located under Sales -> Sales Orders or Sales Invoices. Required fields: Customer No., Posting Date, Line items (Type, No., Quantity, Unit Price). Use "Post" (F9) or "Post and Send" to finalize.\' +
                '- Customer Credit Limit & Block Policy: If a customer balance exceeds their credit limit, orders require Finance Manager approval. Customers can be set to Blocked (Ship/Invoice/All) on the Customer Card.\' +
                '- Payment Terms: Standard terms are Net 30, COD, or 1M(8D). Checked against customer ledger entries and due dates.\' +
                '- AI Customer Assistant Extension: Adds an "AI Insights" action on Customer Card and List to run executive risk analysis and draft context-aware outreach emails.\' +
                '- AI Setup Page: Search "AI Setup" via Alt+Q to configure API Endpoint, Model, and API Key.\\' +
                'User Question: %1\\' +
                'Answer in a helpful, structured tone with numbered steps and bold UI terms.',
                UserQuestion
            );
            if TryAskAI(Prompt, Answer) then
                exit(Answer);
        end;

        // Built-in ERP Knowledge Base Fallback
        exit(GetBuiltInERPAnswer(UserQuestion));
    end;

    local procedure GetBuiltInERPAnswer(UserQuestion: Text): Text
    var
        LowerQ: Text;
    begin
        LowerQ := LowerCase(UserQuestion);

        if (LowerQ.Contains('alt+q')) or (LowerQ.Contains('tell me')) or (LowerQ.Contains('find') and LowerQ.Contains('page')) or (LowerQ.Contains('search')) or (LowerQ.Contains('navigate')) then
            exit('**How to Navigate with Tell Me (Alt+Q):**\' +
                 '1. Press **Alt+Q** (or click the search magnifying glass at the top right).' +
                 '\2. Type the name of the page, report, or feature (e.g., *Customers*, *Sales Invoices*, or *AI Setup*).' +
                 '\3. Press **Enter** or click from the matching results to jump directly there.');

        if (LowerQ.Contains('sales invoice')) or (LowerQ.Contains('invoice')) or (LowerQ.Contains('create') and LowerQ.Contains('sales')) then
            exit('**How to Create & Post a Sales Invoice:**\' +
                 '1. Press **Alt+Q** and search for **Sales Invoices**, then choose **+ New**.' +
                 '\2. In the **Customer Name** field, select your customer.' +
                 '\3. Under **Lines**, set Type = *Item*, select the Item No., and specify Quantity.' +
                 '\4. Review prices, totals, and posting dates.' +
                 '\5. Click **Posting -> Post (F9)** or **Post and Send** to finalize.');

        if (LowerQ.Contains('credit limit')) or (LowerQ.Contains('credit')) or (LowerQ.Contains('block')) then
            exit('**Customer Credit Limit & Policy:**\' +
                 '1. Open any **Customer Card** via **Alt+Q -> Customers**.' +
                 '\2. Expand the **Payments** / **General** FastTab to view or adjust the **Credit Limit (LCY)**.' +
                 '\3. If an order causes the customer balance to exceed this limit, Business Central triggers a credit limit warning.' +
                 '\4. You can set **Blocked** to *Ship*, *Invoice*, or *All* to freeze transactions.');

        if (LowerQ.Contains('customer assistant')) or (LowerQ.Contains('assistant')) or (LowerQ.Contains('health')) or (LowerQ.Contains('email')) then
            exit('**How the AI Customer Assistant Works:**\' +
                 '1. Open any **Customer Card** or **Customer List**.' +
                 '\2. Click the promoted **AI Insights** action.' +
                 '\3. The assistant automatically evaluates total balance, sales velocity, payment terms, and churn risk.' +
                 '\4. Click **Draft Email with AI** to generate a personalized outreach email tailored to account metrics.');

        if (LowerQ.Contains('who are you')) or (LowerQ.Contains('hello')) or (LowerQ.Contains('hi')) or (LowerQ.Contains('amira')) then
            exit('Hello! I am **Amira**, your ERP Assistant for Microsoft Dynamics 365 Business Central. Ask me anything about navigating Business Central, posting invoices, managing credit limits, or configuring AI features!');

        exit('To enable full live generative AI for arbitrary questions, please configure your **Groq API Key** in Business Central:\' +
             '1. Press **Alt+Q** and search for **AI Setup**.' +
             '\2. Enter your Groq API Key (`gsk_...`).' +
             '\3. Set Model Name to `llama-3.3-70b-versatile`.' +
             '\4. Click **Test AI Connection** to verify.');
    end;

    [TryFunction]
    procedure TryAskERPGuide(UserQuestion: Text; var AnswerText: Text)
    begin
        AnswerText := AskERPGuide(UserQuestion);
    end;
}
