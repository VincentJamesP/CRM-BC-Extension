page 70153 "Moo.API Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Moo.API Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("API Function"; Rec."API Function")
                {
                    ApplicationArea = all;
                }
                field(URL; Rec.Path)
                {
                    ApplicationArea = all;
                }
                field(Method; Rec.Method)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit(true);
    end;
}
