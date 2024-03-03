codeunit 70178 "Moo.Warehouse Shipment Model" implements "Moo.IModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
    end;
}
