codeunit 70165 "Moo.Model.Bin" implements "Moo.IModel"
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
    procedure ToJsonBin(var BinTempTable: Record "Moo.BinTempTable" temporary): Text
    var
        JsnObjectText: Text;
        JsnObject: JsonObject;
        JsnArray: JsonArray;
        JsnArrayText: Text;
    begin
        BinTempTable.SetCurrentKey(Company, "Location Code", Zone, "Bin Code");
        BinTempTable.SetAscending(Company, true);
        if BinTempTable.FindSet() then
            repeat
                Clear(JsnObject);
                JsnObject.Add('Company', BinTempTable.Company);
                JsnObject.Add('Location', BinTempTable."Location Code");
                JsnObject.Add('Zone', BinTempTable.Zone);
                JsnObject.Add('Bin', BinTempTable."Bin Code");
                JsnObject.WriteTo(JsnObjectText);

                JsnArray.Add(JsnObject);

            until BinTempTable.Next() = 0;
        JsnArray.WriteTo(JsnArrayText);
        exit(JsnArrayText);
    end;
}
