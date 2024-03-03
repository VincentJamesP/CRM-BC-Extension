table 70150 "Moo.CustomerPayments"
{
    Caption = 'Moo.CustomerPayments';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Payment Code"; Code[20])
        {
            Caption = 'Payment Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Company Payment Code"; Code[20])
        {
            Caption = 'Company Payment Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('CUSTOMERPAYMENT'));
        }
        field(3; "Bal. G/L Acct. No."; Code[20])
        {
            Caption = 'Bal. G/L Acct. No.';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
    }
    keys
    {
        key(PK; "Payment Code")
        {
            Clustered = true;
        }
    }
}
