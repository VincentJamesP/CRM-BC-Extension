page 70151 "Moo.CustomerPayments"
{
    ApplicationArea = All;
    Caption = 'Moo Customer Payments';
    PageType = List;
    SourceTable = "Moo.CustomerPayments";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Payment Code"; Rec."Payment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Code field.';
                }
                field("Company Payment Code"; Rec."Company Payment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Payment Code field.';
                }
                field("Bal. G/L Acct. No."; Rec."Bal. G/L Acct. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Balancing G/L Account No. corresponding to the Payment Code.';
                }
            }
        }
    }
}
