
codeunit 80003 "Test - Update WHSE Shipment"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Source: Text;
        TransType: Integer;
        FunctionType: Integer;
        JSONData: Text;
        MooAPI: Codeunit "Moo.API";
        WHSEShipmentDetail: JsonObject;
        WHSEShipmentDetails: JsonArray;
        Response: Text;

    trigger OnRun()
    begin
        Source := 'LAZADA';
        TransType := 3; // Warehouse Shipment
        FunctionType := 1; // UpdateShipmentProviderTrackingNumber
        // Generate sample JSON Data
        WHSEShipmentDetail.Add('No', 'WHSHP000000009');
        WHSEShipmentDetail.Add('Moo Package ID', 'MPID0001');
        WHSEShipmentDetail.Add('Tracking Number', 'TR00001');
        WHSEShipmentDetail.Add('Shipment Provider', 'SP00001');
        WHSEShipmentDetails.Add(WHSEShipmentDetail);
        WHSEShipmentDetails.WriteTo(JSONData);
    end;

    [Test]
    procedure TestAPIResponse()
    begin
        Response := MooAPI.Update(Source, TransType, FunctionType, JSONData);
        asserterror TestFieldIfEmpty(Response);
    end;

    local procedure TestFieldIfEmpty(FieldValue: Text)
    begin
        if FieldValue <> '' then
            Error(FieldValue);
    end;
}
