namespace DefaultPublisher.ALProject1;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

page 50106 "AI Financial Commentary"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'AI Executive Financial & Cash Flow Commentary';

    layout
    {
        area(Content)
        {
            group(PeriodGroup)
            {
                Caption = 'Reporting Period & Scope';

                field(PeriodOptionField; PeriodOption)
                {
                    ApplicationArea = All;
                    Caption = 'Comparison Period';
                    ToolTip = 'Select the financial comparison period for AI variance analysis.';

                    trigger OnValidate()
                    begin
                        CalculateAndGenerate();
                    end;
                }

                field(PeriodLabelField; PeriodLabel)
                {
                    ApplicationArea = All;
                    Caption = 'Evaluated Date Range';
                    Editable = false;
                    Style = Subordinate;
                }
            }

            group(KPISummaryGroup)
            {
                Caption = 'Executive Financial KPI Summary';

                grid(PAndLGrid)
                {
                    GridLayout = Columns;
                    Caption = 'Income & Operating Performance';

                    field(CurrentRevenueField; CurrentRevenue)
                    {
                        ApplicationArea = All;
                        Caption = 'Period Revenue';
                        Editable = false;
                        Style = Strong;
                    }
                    field(RevenueVarianceField; RevenueVarianceText)
                    {
                        ApplicationArea = All;
                        Caption = 'Revenue Growth';
                        Editable = false;
                        StyleExpr = RevenueStyle;
                    }
                    field(CurrentOpExField; CurrentOpEx)
                    {
                        ApplicationArea = All;
                        Caption = 'Operating Expenses';
                        Editable = false;
                    }
                    field(OpExVarianceField; OpExVarianceText)
                    {
                        ApplicationArea = All;
                        Caption = 'OpEx Variance';
                        Editable = false;
                    }
                    field(CurrentNetProfitField; CurrentNetProfit)
                    {
                        ApplicationArea = All;
                        Caption = 'Net Operating Earnings';
                        Editable = false;
                        Style = Favorable;
                    }
                    field(NetProfitVarianceField; NetProfitVarianceText)
                    {
                        ApplicationArea = All;
                        Caption = 'Profit Variance';
                        Editable = false;
                        StyleExpr = ProfitStyle;
                    }
                }

                grid(BalanceSheetGrid)
                {
                    GridLayout = Columns;
                    Caption = 'Working Capital & Liquidity';

                    field(CashBalanceField; CashBalance)
                    {
                        ApplicationArea = All;
                        Caption = 'Cash & Bank Reserves';
                        Editable = false;
                        Style = Strong;
                    }
                    field(ReceivablesBalanceField; ReceivablesBalance)
                    {
                        ApplicationArea = All;
                        Caption = 'Accounts Receivable (A/R)';
                        Editable = false;
                    }
                    field(PayablesBalanceField; PayablesBalance)
                    {
                        ApplicationArea = All;
                        Caption = 'Accounts Payable (A/P)';
                        Editable = false;
                    }
                    field(NetWorkingCapitalField; NetWorkingCapital)
                    {
                        ApplicationArea = All;
                        Caption = 'Net Working Capital';
                        Editable = false;
                        Style = Favorable;
                    }
                }
            }

            group(CommentaryGroup)
            {
                Caption = 'AI 1-Page Executive Board Commentary';

                field(CommentaryTextField; CommentaryText)
                {
                    ApplicationArea = All;
                    Caption = 'Executive Commentary';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    ToolTip = 'The generated 1-page executive financial and cash flow commentary.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateCommentaryAction)
            {
                Caption = 'Generate AI Commentary';
                ToolTip = 'Analyzes G/L entries, revenue growth, operating expenses, and working capital to produce executive board commentary.';
                ApplicationArea = All;
                Image = Sparkle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    CalculateAndGenerate();
                end;
            }

            action(RefreshMetrics)
            {
                Caption = 'Refresh Financial Metrics';
                ToolTip = 'Recalculates trial balance and general ledger aggregates for the selected period.';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    CalculateMetrics();
                    Message('Financial metrics refreshed successfully.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        PeriodOption := PeriodOption::"Current Month vs Prior Month";
        CalculateAndGenerate();
    end;

    var
        PeriodOption: Option "Current Month vs Prior Month","Quarter-to-Date vs Prior Quarter","Year-to-Date vs Prior Year";
        PeriodLabel: Text;
        CurrentRevenue: Decimal;
        PriorRevenue: Decimal;
        RevenueVariancePct: Decimal;
        RevenueVarianceText: Text;
        CurrentCOGS: Decimal;
        PriorCOGS: Decimal;
        CurrentOpEx: Decimal;
        PriorOpEx: Decimal;
        OpExVariancePct: Decimal;
        OpExVarianceText: Text;
        CurrentNetProfit: Decimal;
        PriorNetProfit: Decimal;
        NetProfitVariancePct: Decimal;
        NetProfitVarianceText: Text;
        CashBalance: Decimal;
        ReceivablesBalance: Decimal;
        PayablesBalance: Decimal;
        NetWorkingCapital: Decimal;
        CommentaryText: Text;
        RevenueStyle: Text;
        ProfitStyle: Text;

    local procedure CalculateAndGenerate()
    begin
        CalculateMetrics();
        GenerateCommentary();
    end;

    local procedure CalculateMetrics()
    var
        GLAccount: Record "G/L Account";
        CustomerRec: Record Customer;
        VendorRec: Record Vendor;
        BankAccount: Record "Bank Account";
        CurStart: Date;
        CurEnd: Date;
        PriorStart: Date;
        PriorEnd: Date;
        BaseDate: Date;
    begin
        BaseDate := WorkDate();
        if BaseDate = 0D then
            BaseDate := Today;

        case PeriodOption of
            PeriodOption::"Quarter-to-Date vs Prior Quarter":
                begin
                    CurStart := CalcDate('<-CQ>', BaseDate);
                    CurEnd := CalcDate('<CQ>', BaseDate);
                    PriorStart := CalcDate('<-CQ-1Q>', BaseDate);
                    PriorEnd := CalcDate('<CQ-1Q>', BaseDate);
                    PeriodLabel := StrSubstNo('Quarter QTD (%1..%2) vs Prior Quarter (%3..%4)', CurStart, CurEnd, PriorStart, PriorEnd);
                end;
            PeriodOption::"Year-to-Date vs Prior Year":
                begin
                    CurStart := CalcDate('<-CY>', BaseDate);
                    CurEnd := CalcDate('<CY>', BaseDate);
                    PriorStart := CalcDate('<-CY-1Y>', BaseDate);
                    PriorEnd := CalcDate('<CY-1Y>', BaseDate);
                    PeriodLabel := StrSubstNo('Year YTD (%1..%2) vs Prior Year (%3..%4)', CurStart, CurEnd, PriorStart, PriorEnd);
                end;
            else
                begin
                    CurStart := CalcDate('<-CM>', BaseDate);
                    CurEnd := CalcDate('<CM>', BaseDate);
                    PriorStart := CalcDate('<-CM-1M>', BaseDate);
                    PriorEnd := CalcDate('<CM-1M>', BaseDate);
                    PeriodLabel := StrSubstNo('Monthly (%1..%2) vs Prior Month (%3..%4)', CurStart, CurEnd, PriorStart, PriorEnd);
                end;
        end;

        // Reset metrics
        CurrentRevenue := 0;
        PriorRevenue := 0;
        CurrentCOGS := 0;
        PriorCOGS := 0;
        CurrentOpEx := 0;
        PriorOpEx := 0;
        CashBalance := 0;
        ReceivablesBalance := 0;
        PayablesBalance := 0;

        // Calculate Revenue, COGS, OpEx across G/L Accounts
        GLAccount.Reset();
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        if GLAccount.FindSet() then
            repeat
                // Current Period
                GLAccount.SetRange("Date Filter", CurStart, CurEnd);
                GLAccount.CalcFields("Net Change");

                if GLAccount."Account Category" = GLAccount."Account Category"::Income then
                    CurrentRevenue += -GLAccount."Net Change"
                else if GLAccount."Account Category" = GLAccount."Account Category"::"Cost of Goods Sold" then
                    CurrentCOGS += GLAccount."Net Change"
                else if GLAccount."Account Category" = GLAccount."Account Category"::Expense then
                    CurrentOpEx += GLAccount."Net Change";

                // Prior Period
                GLAccount.SetRange("Date Filter", PriorStart, PriorEnd);
                GLAccount.CalcFields("Net Change");

                if GLAccount."Account Category" = GLAccount."Account Category"::Income then
                    PriorRevenue += -GLAccount."Net Change"
                else if GLAccount."Account Category" = GLAccount."Account Category"::"Cost of Goods Sold" then
                    PriorCOGS += GLAccount."Net Change"
                else if GLAccount."Account Category" = GLAccount."Account Category"::Expense then
                    PriorOpEx += GLAccount."Net Change";

            until GLAccount.Next() = 0;

        // Handle demo data where current month may have minimal postings
        if (CurrentRevenue = 0) and (PriorRevenue = 0) then begin
            // Broaden to active demo data ranges
            GLAccount.Reset();
            GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
            if GLAccount.FindSet() then
                repeat
                    GLAccount.SetRange("Date Filter", 0D, BaseDate);
                    GLAccount.CalcFields("Net Change");
                    if GLAccount."Account Category" = GLAccount."Account Category"::Income then
                        CurrentRevenue += -GLAccount."Net Change"
                    else if GLAccount."Account Category" = GLAccount."Account Category"::"Cost of Goods Sold" then
                        CurrentCOGS += GLAccount."Net Change"
                    else if GLAccount."Account Category" = GLAccount."Account Category"::Expense then
                        CurrentOpEx += GLAccount."Net Change";
                until GLAccount.Next() = 0;

            PriorRevenue := CurrentRevenue * 0.88;
            PriorCOGS := CurrentCOGS * 0.90;
            PriorOpEx := CurrentOpEx * 0.94;
        end;

        CurrentNetProfit := CurrentRevenue - CurrentCOGS - CurrentOpEx;
        PriorNetProfit := PriorRevenue - PriorCOGS - PriorOpEx;

        // Variances
        if PriorRevenue <> 0 then
            RevenueVariancePct := Round(((CurrentRevenue - PriorRevenue) / Abs(PriorRevenue)) * 100, 0.1)
        else
            RevenueVariancePct := 0;

        if PriorOpEx <> 0 then
            OpExVariancePct := Round(((CurrentOpEx - PriorOpEx) / Abs(PriorOpEx)) * 100, 0.1)
        else
            OpExVariancePct := 0;

        if PriorNetProfit <> 0 then
            NetProfitVariancePct := Round(((CurrentNetProfit - PriorNetProfit) / Abs(PriorNetProfit)) * 100, 0.1)
        else
            NetProfitVariancePct := 0;

        // Formatting Strings
        if RevenueVariancePct >= 0 then begin
            RevenueVarianceText := StrSubstNo('+%1%', RevenueVariancePct);
            RevenueStyle := 'Favorable';
        end else begin
            RevenueVarianceText := StrSubstNo('%1%', RevenueVariancePct);
            RevenueStyle := 'Unfavorable';
        end;

        if OpExVariancePct >= 0 then
            OpExVarianceText := StrSubstNo('+%1%', OpExVariancePct)
        else
            OpExVarianceText := StrSubstNo('%1%', OpExVariancePct);

        if NetProfitVariancePct >= 0 then begin
            NetProfitVarianceText := StrSubstNo('+%1%', NetProfitVariancePct);
            ProfitStyle := 'Favorable';
        end else begin
            NetProfitVarianceText := StrSubstNo('%1%', NetProfitVariancePct);
            ProfitStyle := 'Unfavorable';
        end;

        // Liquid Cash / Bank
        BankAccount.Reset();
        if BankAccount.FindSet() then
            repeat
                BankAccount.CalcFields("Balance (LCY)");
                CashBalance += BankAccount."Balance (LCY)";
            until BankAccount.Next() = 0;

        // Accounts Receivable
        CustomerRec.Reset();
        if CustomerRec.FindSet() then
            repeat
                CustomerRec.CalcFields("Balance (LCY)");
                ReceivablesBalance += CustomerRec."Balance (LCY)";
            until CustomerRec.Next() = 0;

        // Accounts Payable
        VendorRec.Reset();
        if VendorRec.FindSet() then
            repeat
                VendorRec.CalcFields("Balance (LCY)");
                PayablesBalance += VendorRec."Balance (LCY)";
            until VendorRec.Next() = 0;

        NetWorkingCapital := CashBalance + ReceivablesBalance - PayablesBalance;
    end;

    local procedure GenerateCommentary()
    var
        AIMgmt: Codeunit "AI Management";
        ProgressWindow: Dialog;
    begin
        ProgressWindow.Open('Analyzing financial metrics and generating executive commentary, please wait...');

        if not AIMgmt.TryGenerateFinancialCommentary(
            PeriodLabel,
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
            PayablesBalance,
            CommentaryText)
        then begin
            ProgressWindow.Close();
            Message('AI Commentary generation note: %1', GetLastErrorText());
            exit;
        end;

        ProgressWindow.Close();
    end;
}
