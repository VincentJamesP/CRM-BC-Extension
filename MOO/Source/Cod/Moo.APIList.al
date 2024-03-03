page 70154 "Moo.API List"
{
    ApplicationArea = All;
    Caption = 'Moo API List';
    PageType = List;
    SourceTable = "Moo. API Header";
    UsageCategory = Administration;
    CardPageId = "Moo.API Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Enabled = false;
                field(Channel; Rec.Channel)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Resource field.';
                }
                field("Instance Type"; Rec."Instance Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Channel field.';
                }
            }
        }
    }
}
