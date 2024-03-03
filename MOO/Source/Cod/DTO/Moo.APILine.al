table 70154 "Moo.API Line"
{
    Caption = 'Moo.API Line';
    DataClassification = ToBeClassified;

    fields
    {

        field(1; "API Function"; Enum "Moo.APIFunctionsEnum")
        {
            Caption = 'API Function';
            DataClassification = ToBeClassified;
        }
        field(2; Channel; Enum "Moo.API Channel")
        {
            Caption = 'Channel';
            DataClassification = ToBeClassified;
        }
        field(3; "Path"; Text[2048])
        {
            Caption = 'Path';
            DataClassification = ToBeClassified;
        }
        field(4; Method; Enum "Moo.API Method Enum")
        {
            Caption = 'Method';
            DataClassification = ToBeClassified;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Channel", "API Function", "Line No.")
        {

        }
    }
    trigger OnInsert()
    begin
        "Line No." := LineNo;
    end;

    procedure LineNO(): Integer
    var
        MooAPILine: Record "Moo.API Line";
        SL: Record "Sales Line";
    begin
        MooAPILine.Reset();
        MooAPILine.SetRange(Channel, Channel);
        MooAPILine.SetRange("API Function", "API Function");
        IF MooAPILine.FindLast() THEN
            EXIT(MooAPILine."Line No." + 1000)
        ELSE
            EXIT(1000);
    end;
}
