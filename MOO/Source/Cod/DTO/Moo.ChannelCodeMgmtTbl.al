table 70156 "Moo Channel Code Mgmt. Table"
{
    Caption = 'Moo Channel Code Mgmt. Table';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Channel Code"; Text[20])
        {
            Caption = 'Channel Code';
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "Sales Channel"; Enum "Moo Sales Channel")
        {
            Caption = 'Sales Channel';
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "Channel Code", "Sales Channel")
        {
            Clustered = true;
        }
    }
}
