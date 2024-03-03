table 70503 "API.Field Mapping"
{
    Caption = 'API.Field Mapping';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = ToBeClassified;
        }
        field(2; "API Name"; Text[50])
        {
            Caption = 'API Name';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Field Name", "API Name")
        {
            Clustered = true;
        }
    }
}
