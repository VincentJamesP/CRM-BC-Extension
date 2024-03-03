codeunit 70507 "Lazada.OrderStatusSubs"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterRegisterWhseActivity', '', false, false)]
    local procedure OnAfterRegisterWhseActivity(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        LocationRec: Record Location;
        JO: JsonObject;
        OrderStatusModel: Codeunit "Lazada.OrderStatusModel";
        JSONText: Text;
        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        responseText: Text;
        APIList: Record "Moo. API Header";
        packageid: Text;
        shipment_provider: Text;
        tracking_number: Text;
        HelperDomain: Codeunit "Moo.HelperDomain";
    begin
        if WarehouseActivityHeader.Type = WarehouseActivityHeader.Type::Pick then begin
            LocationRec.Get(WarehouseActivityHeader."Location Code");
            if LocationRec."Moo Channel Code" = '' then // Location should have Lazada channel code
                exit;
            APIList := APIHelper.GetAPIHeader(APIChannel::Lazada);
            JO := OrderStatusModel.BuildOrderPackedPayload(APIList."Company ID", WarehouseActivityHeader."No.");
            JO.WriteTo(JSONText);
            // Call API
            responseText := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadaOrderStatusOrderPacked, JSONText, APIMethod::POST);
            Clear(JO);
            JO.ReadFrom(responseText);
            Evaluate(packageid, HelperDomain.GetFieldValue('packageid', JO));
            Evaluate(shipment_provider, HelperDomain.GetFieldValue('shipment_provider', JO));
            Evaluate(tracking_number, HelperDomain.GetFieldValue('tracking_number', JO));
            OrderStatusModel.UpdateWhseShipment(WarehouseActivityHeader."Registering No.", packageid, shipment_provider, tracking_number);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnAfterPostWhseShipment', '', false, false)]
    local procedure OnAfterPostWhseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SuppressCommit: Boolean; var IsHandled: Boolean)
    var
        LocationRec: Record Location;
        JO: JsonObject;
        OrderStatusModel: Codeunit "Lazada.OrderStatusModel";
        JSONText: Text;
        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        logText: Text;
        APIList: Record "Moo. API Header";
    begin
        LocationRec.Get(WarehouseShipmentHeader."Location Code");
        if LocationRec."Moo Channel Code" = '' then // Location should have Lazada channel code
            exit;
        APIList := APIHelper.GetAPIHeader(APIChannel::Lazada);
        JO := OrderStatusModel.BuildOrderForDispatchPayload(APIList."Company ID", WarehouseShipmentHeader);
        JO.WriteTo(JSONText);
        // Call API
        logText := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadaOrderStatusForDispatch, JSONText, APIMethod::POST);

    end;

}
