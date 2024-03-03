codeunit 70409 "Moo.SerialNoTrackingModel" implements "Moo.IModel"
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
