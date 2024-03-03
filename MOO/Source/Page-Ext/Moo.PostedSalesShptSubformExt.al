pageextension 70159 "Moo.PostedSalesShptSubformExt" extends "Posted Sales Shpt. Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Moo Source Sales Order Item ID"; Rec."Moo Source Sales Order Item ID")
            {
                ApplicationArea = All;
                Editable = true;
                Caption = 'Source Sales Order Item ID';
            }
            field("Moo Item Error Code"; Rec."Moo Item Error Code")
            {
                ApplicationArea = All;
                Editable = true;
                Caption = 'Source Item Error Code';
            }
        }
    }
}
