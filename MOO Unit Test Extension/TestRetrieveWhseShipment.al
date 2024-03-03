
codeunit 80004 "Test - Retrieve WHSE Shipment"
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
        FunctionType := 2; // GetBySalesDocNoLineNoItemNo
        // Generate sample JSON Data
        WHSEShipmentDetail.Add('Sales Doc. No.', '101013');
        WHSEShipmentDetail.Add('Sales Line No.', '10000');
        WHSEShipmentDetail.Add('Item No.', 'FEFO');
        WHSEShipmentDetails.Add(WHSEShipmentDetail);
        WHSEShipmentDetails.WriteTo(JSONData);
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
