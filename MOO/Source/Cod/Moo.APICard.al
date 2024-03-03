page 70152 "Moo.API Card"
{
    UsageCategory = Documents;
    Caption = 'MooAPI Card';
    PageType = Card;
    SourceTable = "Moo. API Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Channel; Rec.Channel)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Authorization URL"; Rec."Authorization URL")
                {
                    ApplicationArea = All;
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ApplicationArea = All;
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = All;
                }
                field(Resource; Rec.Resource)
                {
                    ApplicationArea = All;
                }
                field("Base URL"; Rec."Base URL")
                {
                    ApplicationArea = All;
                }
                field("Company ID"; Rec."Company ID")
                {
                    ApplicationArea = All;
                }
                field("Instance Type"; Rec."Instance Type")
                {
                    ApplicationArea = All;
                }
            }
            part(APISubform; "Moo.API Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = Channel = FIELD(Channel);
                UpdatePropagation = Both;
            }
        }
    }
}
