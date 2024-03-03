
codeunit 70653 "Test - Print Airway Bill"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CompanyID: Code[50];
        PackageID: Text;
        CustomerNo: Code[20];
        CustomerRec: Record Customer;
        Request: JsonObject;
        RequestModel: Text;
        AWBModel: Codeunit "Lazada.AirwayBillModel";

        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        Response: Text;

    trigger OnRun()
    begin
        CompanyID := '3388'; // Kation Dev Environment
        PackageID := 'FP039611871601962';
        CustomerNo := 'C00060'; // Kation Technologies, Inc.
    end;

    [Test]
    procedure TestCustomerChannelCode()
    begin
        CustomerRec.Get(CustomerNo);
        asserterror TestFieldIfEmpty(CustomerRec."Moo Channel Code");
    end;

    [Test]
    procedure TestRequestModel()
    begin
        Request := AWBModel.MapRequestHeaders(CompanyID, PackageID, CustomerNo);
        Request.WriteTo(RequestModel);
        asserterror TestFieldIfEmpty(RequestModel);
    end;

    [Test]
    procedure TestAPIConsumption()
    begin
        Response := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadOrderPrintAirwayBill, RequestModel, APIMethod::POST);
        asserterror TestFieldIfEmpty(Response);
    end;

    local procedure TestFieldIfEmpty(FieldValue: Text)
    begin
        if FieldValue <> '' then
            Error(FieldValue);
    end;
}
