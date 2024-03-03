tableextension 70152 "Moo.SalesInvHeaderExt" extends "Sales Invoice Header"
{
    fields
    {
        field(70150; "Moo Source Sales Order ID"; Text[20])
        {
            Caption = 'Source Sales Order ID';
            DataClassification = ToBeClassified;
        }
    }
}
