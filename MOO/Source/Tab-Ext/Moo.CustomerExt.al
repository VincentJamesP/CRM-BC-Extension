tableextension 70159 "Moo Customer Table Extension" extends Customer
{
    fields
    {
        field(70150; "Moo Channel Code"; Text[20])
        {
            Caption = 'Channel Code';
            DataClassification = ToBeClassified;
            TableRelation = "Moo Channel Code Mgmt. Table"."Channel Code";
        }
    }
}
