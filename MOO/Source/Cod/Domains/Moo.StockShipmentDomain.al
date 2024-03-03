codeunit 70163 "Moo.StockShipmentDomain" implements "Moo.IDomain"
{
    var
        ErrText: TextConst ENU = 'Product quantity and count of serial numbers provided must be equal.';

    procedure Create(SourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        SourceData: JsonArray;
        ResponseData: JsonArray;
        StockShipmentResult: Text;
    begin
        SourceData := HelperModel.MapToJsonArray(SourceArr);
        ResponseData := InsertStockShipment(SourceData);
        ResponseData.WriteTo(StockShipmentResult);
        exit(StockShipmentResult);
    end;

    procedure Retrieve(object: Text): Text
    begin
    end;

    procedure Update(object: Text): Text
    begin
    end;

    procedure Delete(object: Text): Text
    begin
    end;

    procedure InsertStockShipment(sourceData: JsonArray): JsonArray;
    var
        StockShipmentModel: Codeunit "Moo.StockShipmentModel";
        ProductQty: Integer;
        QtyCount: Integer;
        HelperDomain: Codeunit "Moo.HelperDomain";
        LoopToken: JsonToken;
        LineToken: JsonToken;
        SerialNumToken: JsonToken;
        JsonObj: JsonObject;
        LineObj: JsonObject;
        LineArray: JsonArray;
        JsonArr: JsonArray;
        ProductSerials: JsonArray;
        ProductSerial: JsonArray;
        ItemLines: JsonArray;
        InvtDocHeader: Record "Invt. Document Header";
        LineNo: Integer;
        ProductSKU: Text;
    begin
        foreach LoopToken in sourceData do begin
            if LoopToken.IsObject() then begin
                // Insert Inventory Document Header and Lines Details
                InvtDocHeader := StockShipmentModel.InsertInvtDocHeader(LoopToken.AsObject());
                ItemLines := HelperDomain.GetArrayValues('lines', LoopToken.AsObject());

                // Insert Inventory Document Line/s
                foreach LineToken in ItemLines do begin
                    if LineToken.IsObject() then begin
                        LineNo += 10000;
                        ProductSKU := StockShipmentModel.InsertInvtDocLine(LineToken.AsObject(), LineNo, InvtDocHeader);


                        // Assign Source Data to Local Parameters 
                        ProductSerial := HelperDomain.GetArrayValues('serialnumbers', LineToken.AsObject());
                        Evaluate(ProductQty, HelperDomain.GetFieldValue('quantity', LineToken.AsObject()));

                        If ProductSerial.Count() = ProductQty then begin
                            // Loop through the serial numbers based on quantity
                            foreach SerialNumToken in ProductSerial do begin
                                if SerialNumToken.IsObject() then begin
                                    StockShipmentModel.InsertItemTrackingLines(SerialNumToken.AsObject(), LineNo, InvtDocHeader."No.");
                                end;
                            end;
                        end else begin
                            Error(ErrText);
                        end;
                        LineObj.Add('LineNo', LineNo);
                        LineObj.Add('SerialNumbers', ProductSerial);
                        LineArray.Add(LineObj);
                        Clear(LineObj);
                    end;
                end;

                // Add output as object to array
                JsonObj.Add('DocNo', InvtDocHeader."No.");
                JsonObj.Add('Lines', LineArray);
                JsonArr.Add(JsonObj);
                Clear(JsonObj);
                Clear(LineNo);
            end;
        end;

        exit(JsonArr);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure PostStockShipment(InvtShipmentDetails: Text): JsonArray;
    var
        DocNo: Text;
        Lines: JsonArray;
        LineNo: Integer;
        SerialNumbers: JsonArray;
        PostedShipments: JsonArray;
        ArrayToken: JsonToken;
        LoopToken: JsonToken;
        LineToken: JsonToken;
        PostedLine: JsonObject;
        PostedLines: JsonArray;
        PostedHeaders: JsonObject;
        PostedShipment: JsonObject;
        InventoryPost: Codeunit "Invt. Doc.-Post Shipment";
        HelperDomain: Codeunit "Moo.HelperDomain";
        InvtDocHeaderTbl: Record "Invt. Document Header";
        InvtShipLineTbl: Record "Invt. Shipment Line";
        ItemLedgerEntryTbl: Record "Item Ledger Entry";
        DocType: Enum "Invt. Doc. Document Type";
    begin
        ArrayToken.ReadFrom(InvtShipmentDetails);
        foreach LoopToken in ArrayToken.AsArray() do begin
            if LoopToken.IsObject() then begin
                // Assign Source Data to Local Parameters
                Evaluate(DocNo, HelperDomain.GetFieldValue('DocNo', LoopToken.AsObject()));
                Lines := HelperDomain.GetArrayValues('Lines', LoopToken.AsObject());

                // Set Filters on Invt. Document Header Table based on current Item
                InvtDocHeaderTbl.Reset();
                InvtDocHeaderTbl.SetCurrentKey("Document Type", "No.");
                InvtDocHeaderTbl.SetRange("Document Type", DocType::Shipment);
                InvtDocHeaderTbl.SetRange("No.", DocNo);
                if InvtDocHeaderTbl.FindFirst() then begin
                    // Post the inserted Inventory Shipment Data
                    InventoryPost.Run(InvtDocHeaderTbl);

                    // Add object to the output
                    PostedHeaders.Add('ShipmentNo', InvtDocHeaderTbl."No.");
                    PostedHeaders.Add('Location', InvtDocHeaderTbl."Location Code");
                    PostedHeaders.Add('Status', Format(InvtDocHeaderTbl.Status));

                    foreach LineToken in Lines do begin
                        if LineToken.IsObject() then begin
                            // Assign Source Data to Local Parameters 
                            SerialNumbers := HelperDomain.GetArrayValues('SerialNumbers', LineToken.AsObject());
                            Evaluate(LineNo, HelperDomain.GetFieldValue('LineNo', LineToken.AsObject()));

                            // Set Filters on Invt. Document Line Table based on current Item
                            InvtShipLineTbl.Reset();
                            InvtShipLineTbl.SetCurrentKey("Line No.");
                            InvtShipLineTbl.SetRange("Shipment No.", InvtDocHeaderTbl."No.");
                            InvtShipLineTbl.SetRange("Line No.", LineNo);
                            if InvtShipLineTbl.FindFirst() then begin
                                // Add output as object to array
                                PostedLine.Add('ProductName', InvtShipLineTbl.Description);
                                PostedLine.Add('SKU', InvtShipLineTbl."Item No.");
                                PostedLine.Add('VariantCode', InvtShipLineTbl."Variant Code");
                                PostedLine.Add('Quantity', InvtShipLineTbl.Quantity);
                                PostedLine.Add('SerialNos', SerialNumbers);
                            end;
                            PostedLines.Add(PostedLine);
                            Clear(PostedLine);
                        end;
                    end;

                    PostedShipment.Add('InvtHeader', PostedHeaders);
                    PostedShipment.Add('InvtLine', PostedLines);
                    PostedShipments.Add(PostedShipment);
                    Clear(PostedShipment);
                end;
            end;
        end;
        exit(PostedShipments);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure GetInventoryShipment(DocNo: Text): Text
    var
        JsonArr: JsonArray;
        JsonArrText: Text;
        JsonObj: JsonObject;
        LineArray: JsonArray;
        LineObj: JsonObject;
        InvtDocHeader: Record "Invt. Document Header";
        InvtDocLine: Record "Invt. Document Line";
        SerialNoArray: JsonArray;
        SerialNoObj: JsonObject;
        ReservEntry: Record "Reservation Entry";
    begin
        Clear(JsonArr);
        Clear(JsonObj);
        Clear(LineArray);
        InvtDocHeader.SetRange("Document Type", InvtDocHeader."Document Type"::Shipment);
        InvtDocHeader.SetRange("No.", DocNo);
        if InvtDocHeader.FindFirst() then begin
            InvtDocLine.SetRange("Document Type", InvtDocLine."Document Type"::Shipment);
            InvtDocLine.SetRange("Document No.", DocNo);
            if InvtDocLine.FindFirst() then
                repeat
                    Clear(SerialNoArray);
                    ReservEntry.SetRange("Source Type", Database::"Invt. Document Line");
                    ReservEntry.SetRange("Source Subtype", InvtDocHeader."Document Type"::Shipment);
                    ReservEntry.SetRange("Source ID", DocNo);
                    ReservEntry.SetRange("Source Ref. No.", InvtDocLine."Line No.");
                    if ReservEntry.FindFirst() then
                        repeat
                            Clear(SerialNoObj);
                            SerialNoObj.Add('serialnumber', ReservEntry."Serial No.");
                            SerialNoArray.Add(SerialNoObj);
                        until ReservEntry.Next() = 0;
                    Clear(LineObj);
                    LineObj.Add('LineNo', InvtDocLine."Line No.");
                    LineObj.Add('SerialNumbers', SerialNoArray);
                    LineArray.Add(LineObj);
                until InvtDocLine.Next() = 0;
            JsonObj.Add('DocNo', DocNo);
            JsonObj.Add('Lines', LineArray);
            JsonArr.Add(JsonObj);
        end;
        JsonArr.WriteTo(JsonArrText);
        exit(JsonArrText);
    end;
}
