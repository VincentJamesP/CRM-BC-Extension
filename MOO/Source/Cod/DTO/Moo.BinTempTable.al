table 70152 "Moo.BinTempTable"
{
    Caption = 'Moo.BinTempTable';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Company; Text[50])
        {
            Caption = 'Company';
            DataClassification = ToBeClassified;
        }
        field(2; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
        }
        field(3; Zone; Code[20])
        {
            Caption = 'Zone Code';
            DataClassification = ToBeClassified;
        }
        field(4; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Company, "Location Code", Zone, "Bin Code")
        {
            Clustered = true;
        }
    }
}
