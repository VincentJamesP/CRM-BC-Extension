codeunit 70418 "Moo.TransferShipmentDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(sourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        sourceData: JsonArray;
        responseData: JsonArray;
        ShipmentsDocuments: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := GetShipmentsByLocation(sourceData);
        responseData.WriteTo(ShipmentsDocuments);
        exit(ShipmentsDocuments);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure GetShipmentsByLocation(SourceData: JsonArray): JsonArray;
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferShipmentModel: Codeunit "Moo.TransferShipmentModel";
        LoopToken: JsonToken;
        JsonObj: JsonObject;
        ResultsArr: JsonArray;
        ProductLocation: Text;
        HelperModel: Codeunit "Moo.HelperModel";
        SourceArray: JsonArray;
    begin
        foreach LoopToken in SourceData do begin
            if LoopToken.IsObject() then begin
                Evaluate(ProductLocation, HelperDomain.GetFieldValue('Store', LoopToken.AsObject()));
                if ResultsArr.Count() <> 0 then begin
                    Clear(ResultsArr);
                end;
                ResultsArr := TransferShipmentModel.MapToJson(ProductLocation);
            end;
        end;
        exit(ResultsArr);
    end;
}
