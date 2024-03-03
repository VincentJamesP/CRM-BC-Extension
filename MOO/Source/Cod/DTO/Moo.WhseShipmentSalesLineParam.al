table 70406 "Moo.WhseShipmentSalesLineParam"
{
    Caption = 'Moo.WhseShipmentSalesLineParam';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            Caption = 'Line No';
            DataClassification = ToBeClassified;
        }
        field(3; "Item No"; Code[20])
        {
            Caption = 'Item No';
            DataClassification = ToBeClassified;
        }
        field(4; "Sales No."; Code[20])
        {
            Caption = 'Item No';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No", "Item No")
        {
            Clustered = true;
        }
        key(Key1; "Document No.")
        {

        }
    }
}
