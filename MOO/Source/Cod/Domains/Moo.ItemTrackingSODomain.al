codeunit 70183 "Moo.ItemTrackingSODomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    var
        itemTrackingModel: Codeunit "Moo.Model.ItemTrackingSO";
    begin
        itemTrackingModel.FromJson(object);
        exit(itemTrackingModel.ToJson());
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(id: text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(id: Text): Text
    begin
    end;

}

