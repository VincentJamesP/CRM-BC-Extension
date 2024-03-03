table 70502 "Lazada.ProductStockTempTable"
{
    Caption = 'Lazada.ProductStockTempTable';
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; companyid; Integer)
        {
            Caption = 'companyid';
            DataClassification = ToBeClassified;
        }
        field(2; product; Text[20])
        {
            Caption = 'product';
            DataClassification = ToBeClassified;
        }
        field(3; qtyonhand; Decimal)
        {
            Caption = 'qtyonhand';
            DataClassification = ToBeClassified;
        }
        field(4; unit; Text[20])
        {
            Caption = 'unit';
            DataClassification = ToBeClassified;
        }
        field(5; warehouse; Text[20])
        {
            Caption = 'warehouse';
            DataClassification = ToBeClassified;
        }
        field(6; kti_storecode; Text[20])
        {
            Caption = 'kti_storecode';
            DataClassification = ToBeClassified;
        }

    }

}

