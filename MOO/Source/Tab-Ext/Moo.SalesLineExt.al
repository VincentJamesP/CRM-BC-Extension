tableextension 70154 "Moo.SalesLineExt" extends "Sales Line"
{
    fields
    {
        field(70150; "Moo Source Sales Order Item ID"; Text[20])
        {
            Caption = 'Source Sales Order Item ID';
            DataClassification = ToBeClassified;
        }
        field(70151; "Moo Item Error Code"; Text[20])
        {
            Caption = 'Item Error Code';
            DataClassification = ToBeClassified;
        }
    }
}