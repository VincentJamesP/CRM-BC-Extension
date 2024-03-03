codeunit 70187 "Moo.PriceDomain" implements "Moo.IDomain"
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
        CampaignDetails: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := GetCampaignDetails(sourceData);
        responseData.WriteTo(CampaignDetails);
        exit(CampaignDetails);
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
    local procedure GetCampaignDetails(sourceData: JsonArray): JsonArray;
    var
        LoopToken: JsonToken;
        CampaignDetails: JsonArray;
        HelperDomain: Codeunit "Moo.HelperDomain";
        CampaignCode: Text;
        PriceModel: Codeunit "Moo.PriceModel";
    begin
        foreach LoopToken in sourceData do begin
            if LoopToken.IsObject() then begin
                Evaluate(CampaignCode, HelperDomain.GetFieldValue('CampaignCode', LoopToken.AsObject()));
                CampaignDetails := PriceModel.MapToJson(CampaignCode);
            end;
        end;
        exit(CampaignDetails);
    end;

}
