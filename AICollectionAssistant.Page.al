namespace DefaultPublisher.ALProject1;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.History;

page 50105 "AI Collection Assistant"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'AI Payment Collection & Invoice Follow-Up';

    layout
    {
        area(Content)
        {
            group(InvoiceSummary)
            {
                Caption = 'Invoice & Overdue Overview';

                grid(OverviewGrid)
                {
                    GridLayout = Columns;
                    ShowCaption = false;

                    field(CustomerNameField; CustomerName)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer';
                        Editable = false;
                        Style = Strong;
                    }
                    field(ContactPersonField; ContactPerson)
                    {
                        ApplicationArea = All;
                        Caption = 'Contact Person';
                        Editable = false;
                    }
                    field(CustomerEmailField; CustomerEmail)
                    {
                        ApplicationArea = All;
                        Caption = 'Recipient E-Mail';
                        Editable = false;
                    }
                    field(DocNoField; DocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Invoice No.';
                        Editable = false;
                        Style = Subordinate;
                    }
                }

                grid(AmountsGrid)
                {
                    GridLayout = Columns;
                    ShowCaption = false;

                    field(DueDateField; DueDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Due Date';
                        Editable = false;
                    }
                    field(DaysOverdueField; DaysOverdue)
                    {
                        ApplicationArea = All;
                        Caption = 'Days Overdue';
                        Editable = false;
                        StyleExpr = OverdueStyle;
                    }
                    field(RemainingAmountField; RemainingAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Outstanding Balance';
                        Editable = false;
                        Style = Unfavorable;
                    }
                    field(CurrencyCodeField; CurrencyCodeDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Currency';
                        Editable = false;
                    }
                }

                field(LineItemsField; LineItemsSummary)
                {
                    ApplicationArea = All;
                    Caption = 'Purchased Items / Services';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Summary of items or services associated with this invoice.';
                }
            }

            group(ToneAndContext)
            {
                Caption = 'Escalation Tone & Goal';

                field(ToneField; EscalationTone)
                {
                    ApplicationArea = All;
                    Caption = 'Tone / Urgency Level';
                    ToolTip = 'Select the tone style for the AI collection drafter.';

                    trigger OnValidate()
                    begin
                        DraftEmail();
                    end;
                }
                field(CustomNotesField; CustomNotes)
                {
                    ApplicationArea = All;
                    Caption = 'Custom Notes / Deadlines';
                    ToolTip = 'Enter any specific notes, agreed payment dates, or special instructions for the AI.';
                }
            }

            group(EmailDraft)
            {
                Caption = 'Generated Collection Message';

                field(EmailSubjectField; EmailSubjectText)
                {
                    ApplicationArea = All;
                    Caption = 'Email Subject';
                    ToolTip = 'The generated email subject line.';
                }
                field(EmailBodyField; EmailBodyText)
                {
                    ApplicationArea = All;
                    Caption = 'Email Body';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    ToolTip = 'The generated email body text.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateDraft)
            {
                Caption = 'Draft Email with AI';
                ToolTip = 'Generates or updates the collection email using AI based on the selected tone and invoice metrics.';
                ApplicationArea = All;
                Image = Sparkle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    DraftEmail();
                end;
            }
            action(OpenInMailClient)
            {
                Caption = 'Open in Mail Client (Outlook)';
                ToolTip = 'Opens your default email client with the recipient, subject, and generated message body pre-filled.';
                ApplicationArea = All;
                Image = Mail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    MailtoUrl: Text;
                begin
                    if EmailBodyText = '' then
                        Error('Please generate an email draft before opening the mail client.');

                    MailtoUrl := StrSubstNo(
                        'mailto:%1?subject=%2&body=%3',
                        CustomerEmail,
                        UrlEscape(EmailSubjectText),
                        UrlEscape(EmailBodyText)
                    );

                    Hyperlink(MailtoUrl);
                end;
            }
        }
    }

    var
        CustomerName: Text;
        ContactPerson: Text;
        CustomerEmail: Text;
        DocumentNo: Code[20];
        DueDate: Date;
        DaysOverdue: Integer;
        RemainingAmount: Decimal;
        CurrencyCode: Code[10];
        CurrencyCodeDisplay: Text;
        LineItemsSummary: Text;
        EscalationTone: Text;
        CustomNotes: Text;
        EmailSubjectText: Text;
        EmailBodyText: Text;
        OverdueStyle: Text;

    procedure SetFromCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        CustomerRec: Record Customer;
    begin
        DocumentNo := CustLedgerEntry."Document No.";
        DueDate := CustLedgerEntry."Due Date";
        CustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");

        if CustLedgerEntry."Remaining Amount" <> 0 then
            RemainingAmount := CustLedgerEntry."Remaining Amount"
        else
            RemainingAmount := CustLedgerEntry."Remaining Amt. (LCY)";

        CurrencyCode := CustLedgerEntry."Currency Code";
        if CurrencyCode = '' then
            CurrencyCodeDisplay := 'LCY'
        else
            CurrencyCodeDisplay := CurrencyCode;

        CustomerName := CustLedgerEntry."Customer Name";
        if CustomerRec.Get(CustLedgerEntry."Customer No.") then begin
            if CustomerName = '' then
                CustomerName := CustomerRec.Name;
            ContactPerson := CustomerRec.Contact;
            CustomerEmail := CustomerRec."E-Mail";
        end;

        CalculateOverdueAndTone();
        DraftEmail();
    end;

    procedure SetFromSalesInvoiceHeader(var SalesInvHeader: Record "Sales Invoice Header")
    var
        CustomerRec: Record Customer;
        SalesInvLine: Record "Sales Invoice Line";
        ItemsList: Text;
    begin
        DocumentNo := SalesInvHeader."No.";
        DueDate := SalesInvHeader."Due Date";
        SalesInvHeader.CalcFields("Amount Including VAT");
        RemainingAmount := SalesInvHeader."Amount Including VAT";

        CurrencyCode := SalesInvHeader."Currency Code";
        if CurrencyCode = '' then
            CurrencyCodeDisplay := 'LCY'
        else
            CurrencyCodeDisplay := CurrencyCode;

        CustomerName := SalesInvHeader."Bill-to Name";
        if CustomerName = '' then
            CustomerName := SalesInvHeader."Sell-to Customer Name";

        ContactPerson := SalesInvHeader."Bill-to Contact";
        if ContactPerson = '' then
            ContactPerson := SalesInvHeader."Sell-to Contact";

        if CustomerRec.Get(SalesInvHeader."Bill-to Customer No.") then begin
            if ContactPerson = '' then
                ContactPerson := CustomerRec.Contact;
            CustomerEmail := CustomerRec."E-Mail";
        end else if CustomerRec.Get(SalesInvHeader."Sell-to Customer No.") then begin
            if ContactPerson = '' then
                ContactPerson := CustomerRec.Contact;
            CustomerEmail := CustomerRec."E-Mail";
        end;

        // Collect invoice line items summary
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                if (SalesInvLine.Description <> '') and (SalesInvLine.Quantity <> 0) then begin
                    if ItemsList <> '' then
                        ItemsList += ', ';
                    ItemsList += StrSubstNo('%1 (%2 %3)', SalesInvLine.Description, SalesInvLine.Quantity, SalesInvLine."Unit of Measure Code");
                end;
            until SalesInvLine.Next() = 0;

        LineItemsSummary := ItemsList;

        CalculateOverdueAndTone();
        DraftEmail();
    end;

    local procedure CalculateOverdueAndTone()
    begin
        if DueDate <> 0D then begin
            if Today > DueDate then
                DaysOverdue := Today - DueDate
            else
                DaysOverdue := 0;
        end else
            DaysOverdue := 0;

        if DaysOverdue > 45 then begin
            OverdueStyle := 'Unfavorable';
            EscalationTone := 'Urgent / Credit Hold Warning';
        end else if DaysOverdue > 15 then begin
            OverdueStyle := 'Attention';
            EscalationTone := 'Firm Follow-up';
        end else begin
            OverdueStyle := 'Favorable';
            EscalationTone := 'Friendly Reminder';
        end;
    end;

    local procedure DraftEmail()
    var
        AIMgmt: Codeunit "AI Management";
        ProgressWindow: Dialog;
    begin
        ProgressWindow.Open('Drafting collection email with AI, please wait...');

        if not AIMgmt.TryGenerateCollectionEmail(
            CustomerName,
            ContactPerson,
            CustomerEmail,
            DocumentNo,
            DueDate,
            RemainingAmount,
            CurrencyCode,
            DaysOverdue,
            EscalationTone,
            LineItemsSummary,
            CustomNotes,
            EmailSubjectText,
            EmailBodyText)
        then begin
            ProgressWindow.Close();
            Message('Could not connect to AI API: %1', GetLastErrorText());
            exit;
        end;

        ProgressWindow.Close();
    end;

    local procedure UrlEscape(InputString: Text): Text
    var
        CR: Char;
        LF: Char;
        Result: Text;
    begin
        CR := 13;
        LF := 10;
        Result := InputString.Replace('&', '%26');
        Result := Result.Replace('?', '%3F');
        Result := Result.Replace('=', '%3D');
        Result := Result.Replace('#', '%23');
        Result := Result.Replace('+', '%2B');
        Result := Result.Replace(' ', '%20');
        Result := Result.Replace(Format(CR) + Format(LF), '%0D%0A');
        Result := Result.Replace(Format(LF), '%0A');
        Result := Result.Replace('\', '%0D%0A');
        exit(Result);
    end;
}
