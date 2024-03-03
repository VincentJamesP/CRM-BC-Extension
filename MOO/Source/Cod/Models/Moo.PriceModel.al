codeunit 70188 "Moo.PriceModel" implements "Moo.IModel"
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
    procedure MapToJson(CampaignCode: Text): JsonArray;
    var
        SalesPrice: Record "Sales Price";
        Campaign: Record Campaign;
        HelperDomain: Codeunit "Moo.HelperDomain";
        CampaignHeader: JsonObject;
        SalesPriceLine: JsonObject;
        SalesPriceLines: JsonArray;
        CampaignDetail: JsonObject;
        CampaignDetails: JsonArray;
    begin
        // Find and map campaign details
        Campaign.Reset();
        Campaign.SetRange("No.", CampaignCode);
        if Campaign.FindFirst() then begin
            // Find and map sales price line
            SalesPrice.Reset();
            SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Campaign);
            SalesPrice.SetRange("Sales Code", Campaign."No.");
            if SalesPrice.FindSet() then begin
                repeat
                    // Map current sales price record to JSON object
                    SalesPriceLine := HelperDomain.Rec2Json(SalesPrice);
                    SalesPriceLine.Add('Campaign_Description', Campaign.Description);

                    // Map sales price line to array
                    SalesPriceLines.Add(SalesPriceLine);

                    // Clear current sales price line value
                    Clear(SalesPriceLine);
                until SalesPrice.Next() = 0;
            end;
        end;
        exit(SalesPriceLines);
    end;
}