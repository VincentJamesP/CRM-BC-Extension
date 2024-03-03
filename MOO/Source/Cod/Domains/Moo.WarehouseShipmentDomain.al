codeunit 70174 "Moo.WhseShipmentDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(object: Text): Text
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        HelperDomain: Codeunit "Moo.HelperDomain";
        JsnTokenAsArray: JsonToken;
        JsnTokenAsObject: JsonToken;
        DocNo: Code[20];

        HeaderJsonObject: JsonObject;
        HeaderJsonObjectText: Text;

        LineJsonObject: JsonObject;
        LineJsnArray: JsonArray;
        LineJsonObjectText: Text;

        ReturnJsnObject: JsonObject;
        ReturnJsnArray: JsonArray;
        ReturnValue: Text;
    begin
        JsnTokenAsArray.ReadFrom(object);
        foreach JsnTokenAsObject in JsnTokenAsArray.AsArray() do begin
            if DocNo = '' then
                DocNo := HelperDomain.GetFieldValue('No', JsnTokenAsObject.AsObject())
            else
                DocNo := DocNo + '|' + HelperDomain.GetFieldValue('No', JsnTokenAsObject.AsObject());

        end;

        GetWarehouseShipmentHeader(DocNo, WarehouseShipmentHeader);
        GetWarehouseShipmentLine(DocNo, WarehouseShipmentLine);
        if WarehouseShipmentHeader.FindSet() then
            repeat
                Clear(LineJsnArray);
                Clear(LineJsonObjectText);
                HeaderJsonObject := HelperDomain.Rec2Json(WarehouseShipmentHeader);
                GetWarehouseShipmentLine(WarehouseShipmentHeader."No.", WarehouseShipmentLine);
                if WarehouseShipmentLine.FindSet() then
                    repeat

                        Clear(LineJsonObject);

                        LineJsonObject := HelperDomain.Rec2Json(WarehouseShipmentLine);


                        LineJsnArray.Add(LineJsonObject);

                    until WarehouseShipmentLine.Next() = 0;

                LineJsonObject.WriteTo(LineJsonObjectText);
                HeaderJsonObject.Add('Line', LineJsonObjectText);

                ReturnJsnArray.Add(HeaderJsonObject);
            until WarehouseShipmentHeader.Next() = 0;

        ReturnJsnArray.WriteTo(ReturnValue);
        exit(ReturnValue);
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
    local procedure GetWarehouseShipmentHeader(DocNo: Text; var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        Clear(WarehouseShipmentHeader);
        WarehouseShipmentHeader.SetFilter("No.", DocNo);
        if WarehouseShipmentHeader.FindSet() then
            exit;
        exit;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetWarehouseShipmentLine(DocNo: Code[20]; var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
        Clear(WarehouseShipmentLine);
        WarehouseShipmentLine.SetRange("No.", DocNo);
        if WarehouseShipmentLine.FindSet() then
            exit;
        exit;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure UpdateShipmentProviderTrackingNumber(object: Text): Text
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        HelperDomain: Codeunit "Moo.HelperDomain";
        JsnTokenAsArray: JsonToken;
        JsnTokenAsObject: JsonToken;
        DocNo: Code[20];
        ShipmentProvider: Text[20];
        TrackingNumber: Text[20];
        PackageId: Text[20];
        HeaderJsonArray: JsonArray;
        HeaderJSonArrayText: Text;
        HeaderJsonObject: JsonObject;

    begin
        JsnTokenAsArray.ReadFrom(object);
        foreach JsnTokenAsObject in JsnTokenAsArray.AsArray() do begin
            DocNo := HelperDomain.GetFieldValue('No', JsnTokenAsObject.AsObject());
            ShipmentProvider := HelperDomain.GetFieldValue('Moo Package ID', JsnTokenAsObject.AsObject());
            TrackingNumber := HelperDomain.GetFieldValue('Tracking Number', JsnTokenAsObject.AsObject());
            PackageId := HelperDomain.GetFieldValue('Shipment Provider', JsnTokenAsObject.AsObject());

            WarehouseShipmentHeader.SetRange("Moo Package ID", PackageId);
            if WarehouseShipmentHeader.FindSet() then begin
                WarehouseShipmentHeader."Moo Shipment Provider" := ShipmentProvider;
                WarehouseShipmentHeader."Moo Tracking Number" := TrackingNumber;
                WarehouseShipmentHeader.Modify(true);
                HeaderJsonObject := HelperDomain.Rec2Json(WarehouseShipmentHeader);
                HeaderJsonArray.Add(HeaderJsonObject);
            end else begin
                WarehouseShipmentHeader.Reset();
                WarehouseShipmentHeader.SetRange("No.", DocNo);
                if WarehouseShipmentHeader.FindSet() then begin
                    WarehouseShipmentHeader."Moo Shipment Provider" := ShipmentProvider;
                    WarehouseShipmentHeader."Moo Tracking Number" := TrackingNumber;
                    WarehouseShipmentHeader.Modify(true);
                    HeaderJsonObject := HelperDomain.Rec2Json(WarehouseShipmentHeader);
                    HeaderJsonArray.Add(HeaderJsonObject);
                end;
            end;
        end;

        HeaderJsonArray.WriteTo(HeaderJSonArrayText);
        exit(HeaderJSonArrayText);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure GetBySalesDocNoLineNoItemNo(object: Text): Text
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WhseShipmentSalesLineParam: Record "Moo.WhseShipmentSalesLineParam" temporary;
        HelperDomain: Codeunit "Moo.HelperDomain";
        JsnTokenAsArray: JsonToken;
        JsnTokenAsObject: JsonToken;
        SalesDocNo: Code[20];
        SalesLineNo: Integer;
        ItemNo: Text[20];
        PrevDoc: Code[20];
        CurrDoc: Code[20];
        Docfilter: Text;

        HeaderJsonObject: JsonObject;
        HeaderJsonObjectText: Text;

        LineJsonObject: JsonObject;
        LineJsnArray: JsonArray;
        LineJsonObjectText: Text;

        ReturnJsnObject: JsonObject;
        ReturnJsnArray: JsonArray;
        ReturnValue: Text;
    begin
        JsnTokenAsArray.ReadFrom(object);
        foreach JsnTokenAsObject in JsnTokenAsArray.AsArray() do begin
            SalesDocNo := HelperDomain.GetFieldValue('Sales Doc. No.', JsnTokenAsObject.AsObject());
            Evaluate(SalesLineNo, HelperDomain.GetFieldValue('Sales Line No.', JsnTokenAsObject.AsObject()));
            ItemNo := HelperDomain.GetFieldValue('Item No.', JsnTokenAsObject.AsObject());

            WarehouseShipmentLine.SetRange("Source No.", SalesDocNo);
            WarehouseShipmentLine.SetRange("Source Line No.", SalesLineNo);
            WarehouseShipmentLine.SetRange("Item No.", ItemNo);
            if WarehouseShipmentLine.FindSet() then begin
                WhseShipmentSalesLineParam."Document No." := WarehouseShipmentLine."No.";
            end;
            WhseShipmentSalesLineParam."Line No" := SalesLineNo;
            WhseShipmentSalesLineParam."Item No" := ItemNo;
            WhseShipmentSalesLineParam."Sales No." := SalesDocNo;
            WhseShipmentSalesLineParam.Insert();
        end;

        WhseShipmentSalesLineParam.Reset();
        WhseShipmentSalesLineParam.SetCurrentKey("Document No.");
        if WhseShipmentSalesLineParam.FindSet() then
            repeat
                CurrDoc := WhseShipmentSalesLineParam."Document No.";
                if CurrDoc <> PrevDoc then begin
                    PrevDoc := WhseShipmentSalesLineParam."Document No.";

                    if Docfilter = '' then
                        Docfilter := WhseShipmentSalesLineParam."Document No."
                    else
                        Docfilter := Docfilter + '|' + WhseShipmentSalesLineParam."Document No.";
                end;
            until WhseShipmentSalesLineParam.Next() = 0;

        GetWarehouseShipmentHeader(Docfilter, WarehouseShipmentHeader);
        GetWarehouseShipmentLine(Docfilter, WarehouseShipmentLine);
        if WarehouseShipmentHeader.FindSet() then
            repeat
                Clear(LineJsnArray);
                Clear(LineJsonObjectText);
                HeaderJsonObject := HelperDomain.Rec2Json(WarehouseShipmentHeader);
                GetWarehouseShipmentLine(WarehouseShipmentHeader."No.", WarehouseShipmentLine);
                if WarehouseShipmentLine.FindSet() then
                    repeat

                        Clear(LineJsonObject);

                        LineJsonObject := HelperDomain.Rec2Json(WarehouseShipmentLine);


                        LineJsnArray.Add(LineJsonObject);

                    until WarehouseShipmentLine.Next() = 0;

                LineJsonObject.WriteTo(LineJsonObjectText);
                HeaderJsonObject.Add('Line', LineJsonObjectText);

                ReturnJsnArray.Add(HeaderJsonObject);
            until WarehouseShipmentHeader.Next() = 0;

        ReturnJsnArray.WriteTo(ReturnValue);
        exit(ReturnValue);
    end;

}
