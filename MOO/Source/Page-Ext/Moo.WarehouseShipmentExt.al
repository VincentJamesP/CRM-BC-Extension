pageextension 70155 "Moo.WarehouseShipmentExt" extends "Warehouse Shipment"
{
    layout
    {
        addafter(Shipping)
        {
            group(Channel)
            {
                field("Moo Package ID"; Rec."Moo Package ID")
                {
                    ApplicationArea = all;
                    Editable = true;
                    Caption = 'Package ID';
                    ToolTip = 'Specifies the Package ID';
                }
                field("Moo Tracking Number"; Rec."Moo Tracking Number")
                {
                    ApplicationArea = all;
                    Editable = true;
                    Caption = 'Tracking Number';
                    ToolTip = 'Specifies the Tracking Number';
                }
                field("Moo Shipment Provider"; Rec."Moo Shipment Provider")
                {
                    ApplicationArea = all;
                    Editable = true;
                    Caption = 'Shipment Provider';
                    ToolTip = 'Specifies the Shipment Provider';
                }
            }
        }
    }
}
