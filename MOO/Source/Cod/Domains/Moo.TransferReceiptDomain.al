codeunit 70421 "Moo.TransferReceiptDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(sourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        sourceData: JsonArray;
        responseData: JsonArray;
        PostedTransferReceipts: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := PostTransferReceipts(sourceData);
        responseData.WriteTo(PostedTransferReceipts);
        exit(PostedTransferReceipts);
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
    procedure PostTransferReceipts(SourceData: JsonArray): JsonArray;
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferReceiptModel: Codeunit "Moo.TransferReceiptModel";
        LoopToken: JsonToken;
        JsonObj: JsonObject;
        ResultsArr: JsonArray;
        TransferOrderNo: Text;
        HelperModel: Codeunit "Moo.HelperModel";
        SourceArray: JsonArray;
    begin
        foreach LoopToken in SourceData do begin
            if LoopToken.IsObject() then begin
                Evaluate(TransferOrderNo, HelperDomain.GetFieldValue('TransferOrderNo', LoopToken.AsObject()));
                if ResultsArr.Count() <> 0 then begin
                    Clear(ResultsArr);
                end;
                ResultsArr := TransferReceiptModel.MapToJson(TransferOrderNo);
            end;
        end;
        exit(ResultsArr);
    end;
}
