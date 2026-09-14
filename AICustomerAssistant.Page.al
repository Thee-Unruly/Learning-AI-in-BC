namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Customer;

page 50102 "AI Customer Assistant"
{
    PageType = Card;
    Caption = 'AI Executive Account Assistant';
    UsageCategory = None;
    DataCaptionExpression = CustomerRecord.Name;

    layout
    {
        area(Content)
        {
            group(CustomerOverview)
            {
                Caption = 'Customer Overview';
                Collapsible = true;

                grid(HeaderGrid)
                {
                    ShowCaption = false;
                    GridLayout = Columns;

                    field(CustNo; CustomerRecord."No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        Editable = false;
                        Style = Subordinate;
                    }
                    field(CustName; CustomerRecord.Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Company Name';
                        Editable = false;
                        Style = Strong;
                    }
                    field(CustContact; CustomerRecord.Contact)
                    {
                        ApplicationArea = All;
                        Caption = 'Primary Contact';
                        Editable = false;
                    }
                    field(CustEmail; CustomerRecord."E-Mail")
                    {
                        ApplicationArea = All;
                        Caption = 'E-Mail';
                        Editable = false;
                    }
                }

                grid(FinancialsGrid)
                {
                    ShowCaption = false;
                    GridLayout = Columns;

                    field(CustBalance; CustomerRecord."Balance (LCY)")
                    {
                        ApplicationArea = All;
                        Caption = 'Current Balance (LCY)';
                        Editable = false;
                        Style = Attention;
                    }
                    field(CustSales; CustomerRecord."Sales (LCY)")
                    {
                        ApplicationArea = All;
                        Caption = 'Lifetime Sales (LCY)';
                        Editable = false;
                        Style = Favorable;
                    }
                    field(CustCredit; CustomerRecord."Credit Limit (LCY)")
                    {
                        ApplicationArea = All;
                        Caption = 'Credit Limit (LCY)';
                        Editable = false;
                    }
                    field(CustTerms; CustomerRecord."Payment Terms Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Payment Terms';
                        Editable = false;
                    }
                }
            }

            group(AccountAnalysisSection)
            {
                Caption = 'Account Health & Assessment';
                Collapsible = true;

                field(AIAnalysisField; AIAnalysisSummary)
                {
                    ApplicationArea = All;
                    Caption = 'Executive Assessment';
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'AI assessment synthesized from live ERP account metrics.';
                }
            }

            group(EmailDraftingSection)
            {
                Caption = 'Personalized Email Drafter';
                Collapsible = true;

                group(EmailParameters)
                {
                    Caption = 'Email Objective & Context';

                    field(SelectedObjective; EmailObjectiveText)
                    {
                        ApplicationArea = All;
                        Caption = 'Objective';
                        ToolTip = 'Select or type the purpose of this outreach email.';
                    }
                    field(NotesField; AdditionalNotesText)
                    {
                        ApplicationArea = All;
                        Caption = 'Custom Notes for AI';
                        ToolTip = 'Add custom talking points (e.g. mention our new spring catalog, propose a 15-min call on Tuesday).';
                    }
                }

                group(EmailOutput)
                {
                    Caption = 'Generated Message';

                    field(SubjectField; EmailSubjectText)
                    {
                        ApplicationArea = All;
                        Caption = 'Subject';
                        ToolTip = 'Subject line crafted by the AI. You can edit it here directly.';
                    }
                    field(BodyField; EmailBodyText)
                    {
                        ApplicationArea = All;
                        Caption = 'Message Body';
                        MultiLine = true;
                        ToolTip = 'The generated email content. You can review, edit, or copy it directly.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReanalyzeAccount)
            {
                Caption = 'Re-Analyze Account';
                ToolTip = 'Re-evaluate customer metrics with the AI model.';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    RunAnalysis();
                end;
            }
            action(DraftEmail)
            {
                Caption = 'Draft Email with AI';
                ToolTip = 'Generate a personalized outreach email referencing this customer''s account standing.';
                ApplicationArea = All;
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AIMgmt: Codeunit "AI Management";
                begin
                    if EmailObjectiveText = '' then
                        EmailObjectiveText := 'Partnership check-in and exploring new business synergies';

                    AIMgmt.GenerateCustomerEmail(CustomerRecord, EmailObjectiveText, AdditionalNotesText, EmailSubjectText, EmailBodyText);
                    Message('Email draft generated successfully! You can review or edit below, then click "Open in Mail Client".');
                end;
            }
            action(OpenInMailClient)
            {
                Caption = 'Open in Mail Client (Outlook)';
                ToolTip = 'Opens your default email client with the recipient, subject, and generated body filled in.';
                ApplicationArea = All;
                Image = Mail;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MailtoUrl: Text;
                begin
                    if EmailBodyText = '' then
                        Error('Please click "Draft Email with AI" first to generate the email content.');

                    MailtoUrl := StrSubstNo(
                        'mailto:%1?subject=%2&body=%3',
                        CustomerRecord."E-Mail",
                        UrlEscape(EmailSubjectText),
                        UrlEscape(EmailBodyText)
                    );

                    Hyperlink(MailtoUrl);
                end;
            }
        }
    }

    var
        CustomerRecord: Record Customer;
        AIAnalysisSummary: Text;
        EmailObjectiveText: Text;
        AdditionalNotesText: Text;
        EmailSubjectText: Text;
        EmailBodyText: Text;

    procedure SetCustomer(CustNo: Code[20])
    begin
        if CustomerRecord.Get(CustNo) then begin
            CustomerRecord.CalcFields("Balance (LCY)", "Sales (LCY)");
            EmailObjectiveText := 'Partnership check-in and exploring new business synergies';
            RunAnalysis();
        end;
    end;

    local procedure RunAnalysis()
    var
        AIMgmt: Codeunit "AI Management";
        Prompt: Text;
    begin
        Prompt := StrSubstNo(
            'Analyze this customer account in Microsoft Dynamics 365 Business Central:\' +
            'Company: %1 (%2)\' +
            'Primary Contact: %3\' +
            'Current Balance: %4 LCY\' +
            'Lifetime Sales: %5 LCY\' +
            'Credit Limit: %6 LCY\' +
            'Payment Terms: %7\\' +
            'Provide an executive briefing in exactly three concise sections without markdown asterisks:\' +
            'Account Standing: (1-2 sentences on trading status and financial health)\' +
            'Risk Assessment: (Low / Moderate / Elevated with concise rationale)\' +
            'Commercial Strategy: (1-2 actionable next steps for the relationship team)',
            CustomerRecord.Name,
            CustomerRecord."No.",
            CustomerRecord.Contact,
            CustomerRecord."Balance (LCY)",
            CustomerRecord."Sales (LCY)",
            CustomerRecord."Credit Limit (LCY)",
            CustomerRecord."Payment Terms Code"
        );

        AIAnalysisSummary := AIMgmt.AskAI(Prompt);
    end;

    local procedure UrlEscape(InputString: Text): Text
    var
        Result: Text;
    begin
        Result := InputString.Replace('&', '%26');
        Result := Result.Replace('?', '%3F');
        Result := Result.Replace('=', '%3D');
        Result := Result.Replace('#', '%23');
        Result := Result.Replace('+', '%2B');
        Result := Result.Replace(' ', '%20');
        Result := Result.Replace(Chr(13) + Chr(10), '%0D%0A');
        Result := Result.Replace(Chr(10), '%0A');
        Result := Result.Replace('\', '%0D%0A');
        exit(Result);
    end;
}
