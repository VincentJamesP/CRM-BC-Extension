// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 70501 WhseShipmentExt extends "Warehouse Shipment"
{
    layout
    {
        // Adding a new control field 'Print AWB URL' in the group 'General'
        addlast(General)
        {
            field("Print AWB URL"; Rec."Moo AWB URL")
            {
                ApplicationArea = all;
                Editable = false;
                ToolTip = 'Specifies the Airway Bill URL';
            }
        }
    }

    actions
    {
        // Adding a new action group 'Functions' in the 'Creation' area
        addlast("F&unctions")
        {
            action("Generate URL")
            {
                ApplicationArea = All;
                Caption = 'Print Airway Bill';
                Image = PrintDocument;

                trigger OnAction();
                begin
                    Rec."Moo AWB URL" := AirwayBill.GenerateURL(Rec);
                end;
            }
        }
    }
    var
        AirwayBill: Codeunit "Lazada.AirwayBillDomain";
}