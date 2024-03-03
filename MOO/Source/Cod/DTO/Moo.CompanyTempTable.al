table 70153 "Moo.CompanyTempTable"
{
    Caption = 'Moo.TempTable';
    DataClassification = ToBeClassified;
    TableType = Temporary;
    fields
    {
        field(1; Company; Text[50])
        {
            Caption = 'Company';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Company)
        {
            Clustered = true;
        }
    }
}
