codeunit 70502 "Lazada.AirwayBillModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure MapRequestHeaders(var CompanyID: Code[50]; var PackageID: Text; var CustomerNo: Code[20]): JsonObject
    var
        JsonObj: JsonObject;
        CustomerRec: Record Customer;
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        ChannelCode: Text;
    begin
        CustomerRec.Reset();
        CustomerRec.SetRange("No.", CustomerNo);
        if CustomerRec.FindFirst() then begin
            ChannelCode := CustomerRec."Moo Channel Code";
        end;

        JsonObj.Add('companyid', CompanyID);
        JsonObj.Add('packageid', PackageID);
        JsonObj.Add('kti_storecode', ChannelCode);

        exit(JsonObj);
    end;
}
