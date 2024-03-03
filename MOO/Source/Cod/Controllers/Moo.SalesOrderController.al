codeunit 70159 "Moo.SalesOrderController" implements "Moo.IController"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(mooFunction: integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.SalesOrderFunctionEnum";
    begin
        functionsEnum := Enum::"Moo.SalesOrderFunctionEnum".FromInteger(mooFunction);
        case functionsEnum of
            functionsEnum::CreateSO:
                begin
                    exit(CreateSO(object));
                end;
            functionsEnum::CreateSOwithPaymentLines:
                begin
                    exit(CreateSOwithPaymentLines(object));
                end;
            functionsEnum::CreateSOwithPaymentandItemTracking:
                begin
                    exit(CreateSOwithPaymentandItemTracking(object));
                end;
            functionsEnum::CreateSOwithPaymentandWhseShipment:
                begin
                    exit(CreateSOwithPaymentandWhseShipment(object));
                end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(functionID: Integer; object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(functionID: Integer; object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(functionID: Integer; object: Text): Text
    begin
    end;

    local procedure CreateSO(jsonData: Text): Text
    var
        SalesOrderDomain: Codeunit "Moo.SalesOrderDomain";
    begin
        exit(SalesOrderDomain.Create(jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateSOwithPaymentLines(jsonData: Text): Text
    var
        SalesOrderDomain: Codeunit "Moo.SalesOrderDomain";
        CreatedSalesOrders: Text;
        logText: Text;
        HelperModel: Codeunit "Moo.HelperModel";
        paymentDomain: Codeunit "Moo.PaymentSODomain";
    begin
        CreatedSalesOrders := SalesOrderDomain.Create(jsonData);
        logText := paymentDomain.Create(jsonData);
        exit(CreatedSalesOrders);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateSOwithPaymentandItemTracking(jsonData: Text): Text
    var
        SalesOrderDomain: Codeunit "Moo.SalesOrderDomain";
        CreatedSalesOrders: Text;
        logText: Text;
        HelperModel: Codeunit "Moo.HelperModel";
        paymentDomain: Codeunit "Moo.PaymentSODomain";
        itemTrackingDomain: Codeunit "Moo.ItemTrackingSODomain";
    begin
        CreatedSalesOrders := SalesOrderDomain.Create(jsonData);
        logText := itemTrackingDomain.Create(jsonData);
        logText := paymentDomain.Create(jsonData);
        exit(CreatedSalesOrders);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateSOwithPaymentandWhseShipment(jsonData: Text): Text
    var
        SalesOrderDomain: Codeunit "Moo.SalesOrderDomain";
        CreatedSalesOrders: Text;
        logText: Text;
        HelperModel: Codeunit "Moo.HelperModel";
        paymentDomain: Codeunit "Moo.PaymentSODomain";
    begin
        CreatedSalesOrders := SalesOrderDomain.Create(jsonData);
        logText := paymentDomain.Create(jsonData);
        CreatedSalesOrders := CreateWhseShipments(CreatedSalesOrders);
        exit(CreatedSalesOrders);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateWhseShipments(CreatedSO_json: Text): Text
    var
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        SH: Record "Sales Header";
        SO_JArray: JsonArray;
        SO_JObj: JsonObject;
        HelperDomain: Codeunit "Moo.HelperDomain";
        LoopToken: JsonToken;
        OrderNo: Text;
        returnText: Text;
        WhseShipLine: Record "Warehouse Shipment Line";
    begin
        SO_JArray.ReadFrom(CreatedSO_json);
        foreach LoopToken in SO_JArray do begin
            if LoopToken.IsObject() then begin
                Evaluate(OrderNo, HelperDomain.GetFieldValue('OrderNo', LoopToken.AsObject()));
                Clear(SH);
                SH.SetRange("Document Type", SH."Document Type"::Order);
                SH.SetRange("No.", OrderNo);
                if SH.FindFirst() then begin
                    ReleaseSalesDoc.Run(SH);
                    GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SH);
                    Clear(WhseShipLine);
                    WhseShipLine.SetRange("Source Document", WhseShipLine."Source Document"::"Sales Order");
                    WhseShipLine.SetRange("Source No.", OrderNo);
                    if WhseShipLine.FindFirst() then begin
                        LoopToken.AsObject().Add('WhseShipmentNo', WhseShipLine."No.");
                    end;
                end;
            end;
        end;
        SO_JArray.WriteTo(returnText);
        exit(returnText);
    end;
}
