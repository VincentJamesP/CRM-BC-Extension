codeunit 70414 "Moo.InventoryDocDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(sourceArr: Text): Text
    begin
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
    procedure GetDocumentsByDocType(DocType: Enum "Invt. Doc. Document Type"; SourceData: Text): Text;
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        InventoryDocModel: Codeunit "Moo.InventoryDocModel";
        LoopToken: JsonToken;
        JsonObj: JsonObject;
        ResultsArr: JsonArray;
        ProductLocation: Text;
        HelperModel: Codeunit "Moo.HelperModel";
        SourceArray: JsonArray;
        ResponseData: Text;
    begin
        SourceArray := HelperModel.MapToJsonArray(SourceData);
        foreach LoopToken in SourceArray do begin
            if LoopToken.IsObject() then begin
                Evaluate(ProductLocation, HelperDomain.GetFieldValue('Store', LoopToken.AsObject()));
                if ResultsArr.Count() <> 0 then begin
                    Clear(ResultsArr);
                end;
                ResultsArr := InventoryDocModel.MapToJson(DocType, ProductLocation);
            end;
        end;
        ResultsArr.WriteTo(ResponseData);
        exit(ResponseData);
    end;
}
