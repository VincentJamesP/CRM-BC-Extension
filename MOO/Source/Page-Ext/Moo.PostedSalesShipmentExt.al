pageextension 70156 "Moo.PostedSalesShipmentExt" extends "Posted Sales Shipment"
{
    layout
    {
        addafter(Shipping)
        {
            group(Channel)
            {
                field("Moo Source Sales Order ID"; Rec."Moo Source Sales Order ID")
                {
                    ApplicationArea = all;
                    Editable = true;
                    Caption = 'Source Sales Order ID';
                    ToolTip = 'Specifies the Source Sales Order ID';
                }
            }
        }
    }
}
