table 70151 "Moo.LocationTempTable"
{
    Caption = 'Moo.LocationTempTable';
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
    }
    keys
    {
        key(PK; Company, "Location Code")
        {
            Clustered = true;
        }
    }
}

