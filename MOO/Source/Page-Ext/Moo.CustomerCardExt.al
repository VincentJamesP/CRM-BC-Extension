// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 70151 LocationCardExt extends "Location Card"
{
    layout
    {
        // Adding a new control field 'Print AWB URL' in the group 'General'
        addlast(General)
        {
            field("Channel Code"; Rec."Moo Channel Code")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the Channel Code';
            }
        }
    }
}