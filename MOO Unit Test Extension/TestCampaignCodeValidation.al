
codeunit 80001 "Test - CampaignCodeValidation"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Source: Text;
        TransType: Integer;
        FunctionType: Integer;
        JSONData: Text;
        MooAPI: Codeunit "Moo.API";
        CampaignDetail: JsonObject;
        CampaignDetails: JsonArray;
        Response: Text;

    trigger OnRun()
    begin
        Source := 'KIOSK';
        TransType := 4; //Price
        FunctionType := 0; //GetCampaignDetails
        // Generate sample JSON Data
        CampaignDetail.Add('CampaignCode', 'CP0002');
        CampaignDetails.Add(CampaignDetail);
        CampaignDetails.WriteTo(JSONData);
    end;

    [Test]
    procedure TestAPIResponse()
    begin
        Response := MooAPI.Retrieve(Source, TransType, FunctionType, JSONData);
        asserterror TestFieldIfEmpty(Response);
    end;

    local procedure TestFieldIfEmpty(FieldValue: Text)
    begin
        if FieldValue <> '' then
            Error(FieldValue);
    end;
}
