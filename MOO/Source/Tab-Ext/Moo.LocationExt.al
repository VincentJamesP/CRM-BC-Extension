tableextension 70160 "Moo Location Table Extension" extends Location
{
    fields
    {
        field(70160; "Moo Channel Code"; Text[20])
        {
            Caption = 'Channel Code';
            DataClassification = ToBeClassified;
            TableRelation = "Moo Channel Code Mgmt. Table"."Channel Code";
        }
    }
}
