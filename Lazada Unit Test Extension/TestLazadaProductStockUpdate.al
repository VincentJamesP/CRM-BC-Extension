
codeunit 70651 TestLazadaProductStockUpdate
{
    Subtype = Test;
    TestPermissions = Disabled;

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

    trigger OnRun()
    begin
        JO := ProductStockModel.GetProductStocks('3388', 'COF0095', '', 'WLLF01');
        JO.WriteTo(JSONText);
    end;

    [Test]
    procedure TestLocationIfInTransit()
    begin
        LocationRec.Get('WLLF01');
        asserterror LocationRec.TestField("Use As In-Transit", true);
    end;

    [Test]
    procedure TestLocationChannelCode()
    begin
        LocationRec.Get('WLLF01');
        asserterror TestFieldIfEmpty(LocationRec."Moo Channel Code");
    end;

    [Test]
    procedure TestJSONPayload()
    begin
        JO := ProductStockModel.GetProductStocks('3388', 'COF0095', '', 'WLLF01');
        JO.WriteTo(JSONText);
        asserterror TestFieldIfEmpty(JSONText);
    end;

    [Test]
    procedure TestAPIResultText()
    begin
        logText := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadaInventoryUpdateStock, JSONText, APIMethod::POST);
        asserterror TestFieldIfEmpty(logText);
    end;

    local procedure TestFieldIfEmpty(FieldValue: Text)
    begin
        if FieldValue <> '' then
            Error(FieldValue);
    end;
}
