table 70405 TempSerialNoTable
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
        field(3; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = ToBeClassified;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; SKU, Store, "Serial No.")
        {
            Clustered = true;
        }
    }
}