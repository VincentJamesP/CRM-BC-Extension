page 70155 "Moo Channel Code Mgmt."
{
    UsageCategory = Lists;
    Caption = 'Moo Channel Code Mgmt. List';
    PageType = List;
    SourceTable = "Moo Channel Code Mgmt. Table";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Channel Codes';
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Channel"; Rec."Sales Channel")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
