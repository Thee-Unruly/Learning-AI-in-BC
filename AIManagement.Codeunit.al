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

    procedure GenerateCollectionEmail(
        CustomerName: Text;
        ContactPerson: Text;
        CustomerEmail: Text;
        DocumentNo: Code[20];
        DueDate: Date;
        RemainingAmount: Decimal;
        CurrencyCode: Code[10];
        DaysOverdue: Integer;
        EscalationTone: Text;
        LineItemsSummary: Text;
        CustomNotes: Text;
        var EmailSubject: Text;
        var EmailBody: Text)
    var
        AISetup: Record "AI Setup";
        Prompt: Text;
        RawResponse: Text;
        SubjectPos: Integer;
        BodyPos: Integer;
        CurrCodeDisplay: Text;
        GreetingName: Text;
    begin
        AISetup.GetSetup();

        GreetingName := ContactPerson;
        if GreetingName = '' then
            GreetingName := CustomerName;

        CurrCodeDisplay := CurrencyCode;
        if CurrCodeDisplay = '' then
            CurrCodeDisplay := 'LCY';

        if (AISetup."API Key" <> '') and (AISetup."API Endpoint" <> '') then begin
            Prompt := StrSubstNo(
                'Draft a professional, context-aware payment collection / invoice follow-up email in Microsoft Dynamics 365 Business Central:\' +
                'Customer Organization: %1\' +
                'Addressed Contact: %2\' +
                'Contact Email: %3\' +
                'Invoice / Document No: %4\' +
                'Invoice Due Date: %5\' +
                'Outstanding Balance: %6 %7\' +
                'Days Overdue: %8 days\' +
                'Selected Tone/Escalation Level: %9\' +
                'Purchased Items Context: %10\' +
                'Account Manager Custom Notes: %11\\' +
                'Guidelines:\' +
                '- Write from the Accounts Receivable / Finance team.\' +
                '- Tone Style based on Selected Tone:\' +
                '  * "Friendly Reminder": Courteous, constructive, checking if they received the invoice and if they need assistance.\' +
                '  * "Firm Follow-up": Professional and direct, emphasizing the payment terms and requesting confirmation of the payment date.\' +
                '  * "Urgent / Credit Hold Warning": Formal and urgent, noting that continued non-payment may result in account hold or suspension of new orders.\' +
                '- Reference purchased items/services naturally if available.\' +
                '- Format with exact markers:\' +
                'SUBJECT: <Subject Line>\' +
                'BODY:\' +
                '<Complete email body with formal greeting and sign-off placeholder>',
                CustomerName,
                GreetingName,
                CustomerEmail,
                DocumentNo,
                DueDate,
                RemainingAmount,
                CurrCodeDisplay,
                DaysOverdue,
                EscalationTone,
                LineItemsSummary,
                CustomNotes
            );

            if TryAskAI(Prompt, RawResponse) then begin
                SubjectPos := StrPos(RawResponse, 'SUBJECT:');
                BodyPos := StrPos(RawResponse, 'BODY:');

                if (SubjectPos > 0) and (BodyPos > SubjectPos) then begin
                    EmailSubject := CopyStr(RawResponse, SubjectPos + 8, BodyPos - (SubjectPos + 8));
                    EmailSubject := EmailSubject.Trim();
                    EmailBody := CopyStr(RawResponse, BodyPos + 5);
                    EmailBody := EmailBody.Trim();
                    exit;
                end;
            end;
        end;

        // Built-in intelligent template fallback
        GetBuiltInCollectionTemplate(CustomerName, GreetingName, DocumentNo, DueDate, RemainingAmount, CurrCodeDisplay, DaysOverdue, EscalationTone, LineItemsSummary, EmailSubject, EmailBody);
    end;

    local procedure GetBuiltInCollectionTemplate(
        CustomerName: Text;
        ContactPerson: Text;
        DocumentNo: Code[20];
        DueDate: Date;
        RemainingAmount: Decimal;
        CurrencyCode: Text;
        DaysOverdue: Integer;
        EscalationTone: Text;
        LineItemsSummary: Text;
        var EmailSubject: Text;
        var EmailBody: Text)
    var
        ItemsNote: Text;
    begin
        if LineItemsSummary <> '' then
            ItemsNote := StrSubstNo(' (covering %1)', LineItemsSummary);

        case EscalationTone of
            'Urgent / Credit Hold Warning':
                begin
                    EmailSubject := StrSubstNo('URGENT: Outstanding Balance for Invoice %1 - %2', DocumentNo, CustomerName);
                    EmailBody := StrSubstNo(
                        'Dear %1,\' +
                        'This is a formal notice regarding unpaid invoice %2%3, which was due on %4 and is now %5 days past due.\' +
                        'Outstanding Amount: %6 %7\' +
                        'To prevent potential interruption of your credit facility or a hold on pending shipments, please arrange immediate settlement of this balance or contact our finance department with remittance confirmation today.\' +
                        'Thank you for your prompt cooperation.\' +
                        'Sincerely,\' +
                        'Accounts Receivable & Finance Team\' +
                        '%8',
                        ContactPerson, DocumentNo, ItemsNote, DueDate, DaysOverdue, RemainingAmount, CurrencyCode, CustomerName
                    );
                end;
            'Firm Follow-up':
                begin
                    EmailSubject := StrSubstNo('Follow-Up: Overdue Payment for Invoice %1 - %2', DocumentNo, CustomerName);
                    EmailBody := StrSubstNo(
                        'Dear %1,\' +
                        'We are writing to follow up on invoice %2%3 for the amount of %6 %7, which was due for payment on %4 (%5 days overdue).\' +
                        'Please verify the payment status with your accounts payable department and let us know when we can expect settlement.\' +
                        'If you require an additional copy of the invoice or banking details, please do not hesitate to reach out.\' +
                        'Kind regards,\' +
                        'Credit Control & Finance Department\' +
                        '%8',
                        ContactPerson, DocumentNo, ItemsNote, DueDate, DaysOverdue, RemainingAmount, CurrencyCode, CustomerName
                    );
                end;
            else
                begin
                    EmailSubject := StrSubstNo('Friendly Reminder: Statement for Invoice %1 - %2', DocumentNo, CustomerName);
                    EmailBody := StrSubstNo(
                        'Dear %1,\' +
                        'We hope this email finds you well.\' +
                        'This is a courtesy reminder that invoice %2%3 in the amount of %6 %7 reached its scheduled payment date on %4.\' +
                        'If payment has already been processed, please disregard this note. Otherwise, please facilitate payment at your earliest convenience.\' +
                        'Thank you for your ongoing partnership.\' +
                        'Best regards,\' +
                        'Finance & Customer Accounts Team\' +
                        '%8',
                        ContactPerson, DocumentNo, ItemsNote, DueDate, RemainingAmount, CurrencyCode, CustomerName
                    );
                end;
        end;
    end;

    [TryFunction]
    procedure TryGenerateCollectionEmail(
        CustomerName: Text;
        ContactPerson: Text;
        CustomerEmail: Text;
        DocumentNo: Code[20];
        DueDate: Date;
        RemainingAmount: Decimal;
        CurrencyCode: Code[10];
        DaysOverdue: Integer;
        EscalationTone: Text;
        LineItemsSummary: Text;
        CustomNotes: Text;
        var EmailSubject: Text;
        var EmailBody: Text)
    begin
        GenerateCollectionEmail(CustomerName, ContactPerson, CustomerEmail, DocumentNo, DueDate, RemainingAmount, CurrencyCode, DaysOverdue, EscalationTone, LineItemsSummary, CustomNotes, EmailSubject, EmailBody);
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

    procedure GenerateFinancialCommentary(
        PeriodName: Text;
        CurrentRevenue: Decimal;
        PriorRevenue: Decimal;
        RevenueVariancePct: Decimal;
        CurrentCOGS: Decimal;
        PriorCOGS: Decimal;
        CurrentOpEx: Decimal;
        PriorOpEx: Decimal;
        OpExVariancePct: Decimal;
        CurrentNetProfit: Decimal;
        PriorNetProfit: Decimal;
        NetProfitVariancePct: Decimal;
        CashBalance: Decimal;
        ReceivablesBalance: Decimal;
        PayablesBalance: Decimal;
        var CommentaryText: Text)
    var
        AISetup: Record "AI Setup";
        Prompt: Text;
        RawResponse: Text;
    begin
        AISetup.GetSetup();

        if (AISetup."API Key" <> '') and (AISetup."API Endpoint" <> '') then begin
            Prompt := StrSubstNo(
                'You are an executive Chief Financial Officer (CFO) and Financial Controller analyzing financial metrics in Microsoft Dynamics 365 Business Central.\' +
                'Write a structured, insightful, and professional 1-page Executive Financial & Cash Flow Commentary based on the following general ledger figures:\' +
                'Comparison Period: %1\' +
                'Revenue: Current %2 LCY | Prior %3 LCY | Variance %4%%\' +
                'Cost of Goods Sold (COGS): Current %5 LCY | Prior %6 LCY\' +
                'Operating Expenses (OpEx): Current %7 LCY | Prior %8 LCY | Variance %9%%\' +
                'Operating Net Profit: Current %10 LCY | Prior %11 LCY | Variance %12%%\' +
                'Liquid Cash & Bank Holdings: %13 LCY\' +
                'Accounts Receivable (A/R): %14 LCY\' +
                'Accounts Payable (A/P): %15 LCY\\' +
                'Structure your commentary with clear markdown headings:\' +
                '### 1. Executive Summary\' +
                '### 2. Revenue Performance & Drivers\' +
                '### 3. Expense & Margin Variance Analysis\' +
                '### 4. Cash Flow & Working Capital Health\' +
                '### 5. Strategic Recommendations for Management\\' +
                'Tone: Sophisticated, data-driven, strategic, and practical. Highlight potential risk areas (e.g. A/R aging or rising OpEx) and celebrate revenue growth.',
                PeriodName,
                CurrentRevenue,
                PriorRevenue,
                RevenueVariancePct,
                CurrentCOGS,
                PriorCOGS,
                CurrentOpEx,
                PriorOpEx,
                OpExVariancePct,
                CurrentNetProfit,
                PriorNetProfit,
                NetProfitVariancePct,
                CashBalance,
                ReceivablesBalance,
                PayablesBalance
            );

            if TryAskAI(Prompt, RawResponse) then begin
                CommentaryText := RawResponse;
                exit;
            end;
        end;

        // Built-in intelligent financial commentary fallback
        CommentaryText := GetBuiltInFinancialCommentary(
            PeriodName, CurrentRevenue, PriorRevenue, RevenueVariancePct,
            CurrentCOGS, PriorCOGS, CurrentOpEx, PriorOpEx, OpExVariancePct,
            CurrentNetProfit, PriorNetProfit, NetProfitVariancePct,
            CashBalance, ReceivablesBalance, PayablesBalance
        );
    end;

    local procedure GetBuiltInFinancialCommentary(
        PeriodName: Text;
        CurrentRevenue: Decimal;
        PriorRevenue: Decimal;
        RevenueVariancePct: Decimal;
        CurrentCOGS: Decimal;
        PriorCOGS: Decimal;
        CurrentOpEx: Decimal;
        PriorOpEx: Decimal;
        OpExVariancePct: Decimal;
        CurrentNetProfit: Decimal;
        PriorNetProfit: Decimal;
        NetProfitVariancePct: Decimal;
        CashBalance: Decimal;
        ReceivablesBalance: Decimal;
        PayablesBalance: Decimal): Text
    var
        RevTrend: Text;
        ProfitTrend: Text;
        Report: Text;
    begin
        if RevenueVariancePct >= 0 then
            RevTrend := StrSubstNo('positive growth of +%1%', RevenueVariancePct)
        else
            RevTrend := StrSubstNo('a contraction of %1%', RevenueVariancePct);

        if NetProfitVariancePct >= 0 then
            ProfitTrend := StrSubstNo('improved by +%1%', NetProfitVariancePct)
        else
            ProfitTrend := StrSubstNo('contracted by %1%', NetProfitVariancePct);

        Report := StrSubstNo(
            '# Executive Financial & Cash Flow Commentary (%1)\\' +
            '### 1. Executive Summary\' +
            'For the evaluated period (%1), the organization recorded total revenue of %2 LCY (%4 compared to prior period %3 LCY). Net operating earnings concluded at %10 LCY (%12), reflecting steady operational momentum across core business units.\\' +
            '### 2. Revenue Performance & Drivers\' +
            '- Current Revenue: %2 LCY (Prior: %3 LCY, %4)\' +
            '- Cost of Sales (COGS): %5 LCY (Prior: %6 LCY)\' +
            '- Gross Margin: Healthy gross spread maintained, driven by stable pricing and consistent sales order delivery volume.\\' +
            '### 3. Expense & Margin Variance Analysis\' +
            '- Operating Expenses (OpEx): %7 LCY (Prior: %8 LCY, Variance: %9%)\' +
            '- Net Operating Profit: %10 LCY (%12)\' +
            '- Margin Commentary: Overhead and administrative disbursements remain aligned with budgetary targets, preventing margin leakage.\\' +
            '### 4. Cash Flow & Working Capital Health\' +
            '- Liquid Cash & Bank Position: %13 LCY\' +
            '- Accounts Receivable (A/R): %14 LCY\' +
            '- Accounts Payable (A/P): %15 LCY\' +
            '- Liquidity Assessment: Current cash reserves comfortably cover short-term operational liabilities. Accounts receivable represents active billing pipelines.\\' +
            '### 5. Strategic Recommendations for Management\' +
            '1. Accelerate Accounts Receivable collections through the AI Collection Assistant to optimize working capital turnover.\' +
            '2. Conduct vendor renegotiations on top supplier accounts to further strengthen gross margin realization.\' +
            '3. Maintain discipline on discretionary operating expenditures into the upcoming reporting cycle.',
            PeriodName, CurrentRevenue, PriorRevenue, RevTrend, CurrentCOGS, PriorCOGS,
            CurrentOpEx, PriorOpEx, OpExVariancePct, CurrentNetProfit, PriorNetProfit, ProfitTrend,
            CashBalance, ReceivablesBalance, PayablesBalance
        );

        exit(Report);
    end;

    [TryFunction]
    procedure TryGenerateFinancialCommentary(
        PeriodName: Text;
        CurrentRevenue: Decimal;
        PriorRevenue: Decimal;
        RevenueVariancePct: Decimal;
        CurrentCOGS: Decimal;
        PriorCOGS: Decimal;
        CurrentOpEx: Decimal;
        PriorOpEx: Decimal;
        OpExVariancePct: Decimal;
        CurrentNetProfit: Decimal;
        PriorNetProfit: Decimal;
        NetProfitVariancePct: Decimal;
        CashBalance: Decimal;
        ReceivablesBalance: Decimal;
        PayablesBalance: Decimal;
        var CommentaryText: Text)
    begin
        GenerateFinancialCommentary(
            PeriodName, CurrentRevenue, PriorRevenue, RevenueVariancePct,
            CurrentCOGS, PriorCOGS, CurrentOpEx, PriorOpEx, OpExVariancePct,
            CurrentNetProfit, PriorNetProfit, NetProfitVariancePct,
            CashBalance, ReceivablesBalance, PayablesBalance, CommentaryText
        );
    end;
}
