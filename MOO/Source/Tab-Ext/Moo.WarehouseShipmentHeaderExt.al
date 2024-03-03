tableextension 70157 "Moo.WarehouseShipmentHeaderExt" extends "Warehouse Shipment Header"
{
    fields
    {
        field(70150; "Moo Package ID"; Text[20])
        {
            Caption = 'Package ID';
            DataClassification = ToBeClassified;
        }
        field(70151; "Moo Shipment Provider"; Text[20])
        {
            Caption = 'Shipment Provider';
            DataClassification = ToBeClassified;
        }
        field(70152; "Moo Tracking Number"; Text[20])
        {
            Caption = 'Tracking Number';
            DataClassification = ToBeClassified;
        }
        field(70153; "Moo AWB URL"; Text[1024])
        {
            Caption = 'Print AWB URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
    }
}
