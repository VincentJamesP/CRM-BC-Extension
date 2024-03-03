codeunit 70503 "Lazada.CancelOrderModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure MapRequestHeaders(var CompanyID: Code[50]; var CustomerNo: Code[20]; var DocumentNo: Text): JsonObject
    var
        ParametersObj: JsonObject;
        CustomerRec: Record Customer;
        OrderItemIDs: JsonArray;
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ChannelCode: Text;
        PackageID: Text;
    begin
        CustomerRec.Reset();
        CustomerRec.SetRange("No.", CustomerNo);
        if CustomerRec.FindFirst() then begin
            ChannelCode := CustomerRec."Moo Channel Code";
        end;

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        if SalesInvoiceLine.FindSet() then begin
            repeat
                OrderItemIDs.Add(SalesInvoiceLine."Moo Source Sales Order Item ID");
            until SalesInvoiceLine.Next() = 0;
        end;

        ParametersObj.Add('companyid', CompanyID);
        ParametersObj.Add('kti_storecode', ChannelCode);
        ParametersObj.Add('kti_sourcesalesorderitemids', OrderItemIDs);
        ParametersObj.Add('cancelreason', 'Cancellation request');
        ParametersObj.Add('laz_cancelReason', 15);
        exit(ParametersObj);
    end;
}
