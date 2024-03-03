codeunit 70501 "Lazada.AirwayBillDomain" implements "Lazada.IDomain"
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
    procedure GenerateURL(var WhseShipmentHeader: Record "Warehouse Shipment Header"): Text;
    var
        JsonObj: JsonObject;
        JsonText: Text;
        SalesHeader: Record "Sales Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        APIList: Record "Moo. API Header";
        AirwayBillModel: Codeunit "Lazada.AirwayBillModel";
        AirwayBillURL: Text;
    begin
        Clear(AirwayBillURL);
        APIList := APIHelper.GetAPIHeader(APIChannel::Lazada);
        // Find Warehouse Shipment Line of Current Warehouse Shipment Header
        WhseShipmentLine.Reset();
        WhseShipmentLine.SetRange("No.", WhseShipmentHeader."No.");
        WhseShipmentLine.SetRange("Line No.", 10000);
        if WhseShipmentLine.FindFirst() then begin
            // Find Sales Header of Current Warehouse Shipment Line
            SalesHeader.Reset();
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.SetRange("No.", WhseShipmentLine."Source No.");
            if SalesHeader.FindFirst() then begin
                // Map request headers to JsonObject
                JsonObj := AirwayBillModel.MapRequestHeaders(APIList."Company ID", WhseShipmentHeader."Moo Package ID", SalesHeader."Sell-to Customer No.");
                JsonObj.WriteTo(JsonText);

                // Call API
                AirwayBillURL := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadOrderPrintAirwayBill, JSONText, APIMethod::POST);
            end;
        end;

        exit(AirwayBillURL);
    end;

}
