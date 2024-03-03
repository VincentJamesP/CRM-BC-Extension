table 70404 TempItemTable
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; SKU; Code[20])
        {
            Caption = 'SKU';
            DataClassification = ToBeClassified;
        }
        field(2; Store; Code[10])
        {
            Caption = 'Store';
            DataClassification = ToBeClassified;
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; SKU, Store)
        {
            Clustered = true;
        }
    }
}