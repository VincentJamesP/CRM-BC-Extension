
codeunit 70656 "Test - Lazada Ship Order"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CompanyID: Code[50];
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        LocationCode: Code[20];
        LocationRec: Record Location;
        Request: JsonObject;
        RequestModel: Text;
        OrderStatusModel: Codeunit "Lazada.OrderStatusModel";

        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        Response: Text;

    trigger OnRun()
    begin
        CompanyID := '3388'; // Kation Dev Environment
        WhseShipmentHeader.Get('103219'); // Invoice No.
        LocationCode := 'WLLF01'; // Test Location
    end;

    [Test]
    procedure TestLocationChannelCode()
    begin
        LocationRec.Get(LocationCode);
        asserterror TestFieldIfEmpty(LocationRec."Moo Channel Code");
    end;

    [Test]
    procedure TestRequestModel()
    begin
        Request := OrderStatusModel.BuildOrderForDispatchPayload(CompanyID, WhseShipmentHeader);
        Request.WriteTo(RequestModel);
        asserterror TestFieldIfEmpty(RequestModel);
    end;

    [Test]
    procedure TestAPIConsumption()
    begin
        Response := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadaOrderStatusOrderPacked, RequestModel, APIMethod::POST);
        asserterror TestFieldIfEmpty(Response);
    end;

    local procedure TestFieldIfEmpty(FieldValue: Text)
    begin
        if FieldValue <> '' then
            Error(FieldValue);
    end;
}
