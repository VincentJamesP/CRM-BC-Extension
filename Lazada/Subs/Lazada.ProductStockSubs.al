codeunit 70508 "Lazada.ProductStockSubs"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEvent(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    var
        LocationRec: Record Location;
        JO: JsonObject;
        ProductStockModel: Codeunit "Lazada.ProductStockModel";
        JSONText: Text;
        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        logText: Text;
        APIList: Record "Moo. API Header";
    begin
        if not LocationRec.IsInTransit(Rec."Location Code") then begin
            LocationRec.Get(Rec."Location Code");
            if LocationRec."Moo Channel Code" = '' then
                exit;
            APIList := APIHelper.GetAPIHeader(APIChannel::Lazada);
            JO := ProductStockModel.GetProductStocks(APIList."Company ID", Rec."Item No.", Rec."Variant Code", Rec."Location Code");
            JO.WriteTo(JSONText);
            // Call API
            logText := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadaInventoryUpdateStock, JSONText, APIMethod::POST);
        end;
    end;
}
