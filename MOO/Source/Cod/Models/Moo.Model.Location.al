codeunit 70175 "Moo.Model.Location" implements "Moo.IModel"
{

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJsonLocation(var LocationTempTable: Record "Moo.LocationTempTable" temporary): Text
    var
        JsnObjectText: Text;
        JsnObject: JsonObject;
        JsnArray: JsonArray;
        JsnArrayText: Text;
    begin
        LocationTempTable.SetCurrentKey(Company, "Location Code");
        LocationTempTable.SetAscending(Company, true);
        if LocationTempTable.FindSet() then
            repeat
                Clear(JsnObject);
                JsnObject.Add('Company', LocationTempTable.Company);
                JsnObject.Add('Location', LocationTempTable."Location Code");
                JsnObject.WriteTo(JsnObjectText);

                JsnArray.Add(JsnObject);

            until LocationTempTable.Next() = 0;
        JsnArray.WriteTo(JsnArrayText);
        exit(JsnArrayText);
    end;
}
