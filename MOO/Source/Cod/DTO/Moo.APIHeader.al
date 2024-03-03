table 70155 "Moo. API Header"
{
    Caption = 'Moo. API Header';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Channel; Enum "Moo.API Channel")
        {
            Caption = 'Channel';
            DataClassification = ToBeClassified;
        }
        field(2; "Authorization URL"; Text[2048])
        {
            Caption = 'Authorization URL';
            DataClassification = ToBeClassified;
        }
        field(3; "Client ID"; Text[2048])
        {
            Caption = 'Client ID';
            DataClassification = ToBeClassified;
        }
        field(4; "Client Secret"; Text[2048])
        {
            Caption = 'Client Secret';
            DataClassification = ToBeClassified;
        }
        field(5; "Tenant ID"; Text[2048])
        {
            Caption = 'Tenant ID';
            DataClassification = ToBeClassified;
        }
        field(6; Scope; Text[2048])
        {
            Caption = 'Scope';
            DataClassification = ToBeClassified;
        }
        field(7; Resource; Text[2048])
        {
            Caption = 'Resource';
            DataClassification = ToBeClassified;
        }
        field(8; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(9; "Base URL"; Text[2048])
        {
            Caption = 'Base URL';
            DataClassification = ToBeClassified;
        }
        field(10; "Company ID"; Code[50])
        {
            Caption = 'Company ID';
            DataClassification = ToBeClassified;
        }
        field(11; "Auto. Token Generation"; Boolean)
        {
            Caption = 'Auto. Token Generation';
            DataClassification = ToBeClassified;
        }
        field(12; "Token"; Blob)
        {
            Caption = 'Token';
            DataClassification = ToBeClassified;
        }
        field(13; "Instance Type"; Text[100])
        {
            Caption = 'Instance Type';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Channel)
        {
            Clustered = true;
        }
    }
}
