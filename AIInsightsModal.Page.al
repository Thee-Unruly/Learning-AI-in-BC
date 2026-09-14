namespace DefaultPublisher.ALProject1;

page 50102 "AI Insights Modal"
{
    PageType = StandardDialog;
    Caption = '🤖 AI Executive Insights';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(CustomerSummary)
            {
                Caption = '📋 Customer Context';

                field(CustName; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    Editable = false;
                    Style = Strong;
                }
                grid(MetricsGrid)
                {
                    ShowCaption = false;
                    GridLayout = Columns;

                    field(CustNo; CustomerNo)
                    {
                        ApplicationArea = All;
                        Caption = 'No.';
                        Editable = false;
                        Style = Subordinate;
                    }
                    field(CustBalance; CustomerBalance)
                    {
                        ApplicationArea = All;
                        Caption = 'Balance (LCY)';
                        Editable = false;
                        Style = Attention;
                    }
                    field(CustCredit; CustomerCreditLimit)
                    {
                        ApplicationArea = All;
                        Caption = 'Credit Limit';
                        Editable = false;
                        Style = Strong;
                    }
                }
            }

            group(AIAnalysisGroup)
            {
                Caption = '✨ AI Analysis & Recommendations';

                field(AIResult; AIAnalysisText)
                {
                    ApplicationArea = All;
                    Caption = 'AI Insights';
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    var
        CustomerNo: Code[20];
        CustomerName: Text[100];
        CustomerBalance: Decimal;
        CustomerCreditLimit: Decimal;
        AIAnalysisText: Text;

    procedure SetData(CustNo: Code[20]; CustName: Text[100]; Balance: Decimal; CreditLimit: Decimal; Analysis: Text)
    begin
        CustomerNo := CustNo;
        CustomerName := CustName;
        CustomerBalance := Balance;
        CustomerCreditLimit := CreditLimit;
        AIAnalysisText := Analysis;
    end;
}
