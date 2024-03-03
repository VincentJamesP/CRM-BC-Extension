pageextension 70152 "Moo.PostedSalesInvoiceExt" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Shipping and Billing")
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
