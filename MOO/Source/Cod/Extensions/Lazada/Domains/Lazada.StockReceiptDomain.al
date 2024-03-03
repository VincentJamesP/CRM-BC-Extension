codeunit 70173 "Lazada.StockReceiptDomain" implements "Moo.IDomain"
{
    var
        ErrText: TextConst ENU = 'Product quantity and count of serial numbers provided must be equal.';

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(SourceArr: Text): Text;
    var
        HelperModel: Codeunit "Moo.HelperModel";
        SourceData: JsonArray;
        ResponseData: JsonArray;
        StockReceiptResult: Text;
    begin
        SourceData := HelperModel.MapToJsonArray(SourceArr);
        ResponseData := InsertStockReceipt(SourceData);
        ResponseData.WriteTo(StockReceiptResult);
        exit(StockReceiptResult);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(object: Text): Text
    begin

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
    procedure InsertStockReceipt(sourceData: JsonArray): JsonArray;
    var
        StockReceiptModel: Codeunit "Lazada.StockReceiptModel";
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
                // Insert Inventory Document Header
                InvtDocHeader := StockReceiptModel.InsertInvtDocHeader(LoopToken.AsObject());
                ItemLines := HelperDomain.GetArrayValues('lines', LoopToken.AsObject());

                // Insert Inventory Document Line/s
                foreach LineToken in ItemLines do begin
                    if LineToken.IsObject() then begin
                        LineNo += 10000;
                        ProductSKU := StockReceiptModel.InsertInvtDocLine(LineToken.AsObject(), LineNo, InvtDocHeader);

                        // Assign Source Data to Local Parameters 
                        ProductSerial := HelperDomain.GetArrayValues('serialnumbers', LineToken.AsObject());
                        Evaluate(ProductQty, HelperDomain.GetFieldValue('quantity', LineToken.AsObject()));

                        If ProductSerial.Count() = ProductQty then begin
                            // Loop through the serial numbers based on quantity
                            foreach SerialNumToken in ProductSerial do begin
                                if SerialNumToken.IsObject() then begin
                                    StockReceiptModel.InsertItemTrackingLines(SerialNumToken.AsObject(), LineNo, InvtDocHeader."No.");
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
    procedure PostStockReceipt(InvtReceiptDetails: Text): JsonArray;
    var
        DocNo: Text;
        Lines: JsonArray;
        SerialNumbers: JsonArray;
        PostedReceipts: JsonArray;
        PostedReceipt: JsonObject;
        LineNo: Integer;
        ArrayToken: JsonToken;
        LoopToken: JsonToken;
        LineToken: JsonToken;
        PostedLine: JsonObject;
        PostedLines: JsonArray;
        PostedHeaders: JsonObject;
        InventoryPost: Codeunit "Invt. Doc.-Post Receipt";
        HelperDomain: Codeunit "Moo.HelperDomain";
        InvtDocHeaderTbl: Record "Invt. Document Header";
        InvtRecLineTbl: Record "Invt. Receipt Line";
        ItemLedgerEntryTbl: Record "Item Ledger Entry";
        DocType: Enum "Invt. Doc. Document Type";
    begin
        ArrayToken.ReadFrom(InvtReceiptDetails);
        foreach LoopToken in ArrayToken.AsArray() do begin
            if LoopToken.IsObject() then begin
                // Assign Source Data to Local Parameters
                Evaluate(DocNo, HelperDomain.GetFieldValue('DocNo', LoopToken.AsObject()));
                Lines := HelperDomain.GetArrayValues('Lines', LoopToken.AsObject());

                // Set Filters on Invt. Document Header Table based on current Item
                InvtDocHeaderTbl.Reset();
                InvtDocHeaderTbl.SetCurrentKey("Document Type", "No.");
                InvtDocHeaderTbl.SetRange("Document Type", DocType::Receipt);
                InvtDocHeaderTbl.SetRange("No.", DocNo);
                if InvtDocHeaderTbl.FindFirst() then begin
                    // Post the inserted Inventory Receipt Data
                    InventoryPost.Run(InvtDocHeaderTbl);

                    // Add object to the output
                    PostedHeaders.Add('ReceiptNo', InvtDocHeaderTbl."No.");
                    PostedHeaders.Add('Location', InvtDocHeaderTbl."Location Code");
                    PostedHeaders.Add('Status', Format(InvtDocHeaderTbl.Status));

                    foreach LineToken in Lines do begin
                        if LineToken.IsObject() then begin
                            // Assign Source Data to Local Parameters 
                            SerialNumbers := HelperDomain.GetArrayValues('SerialNumbers', LineToken.AsObject());
                            Evaluate(LineNo, HelperDomain.GetFieldValue('LineNo', LineToken.AsObject()));

                            // Set Filters on Invt. Document Line Table based on current Item
                            InvtRecLineTbl.Reset();
                            InvtRecLineTbl.SetCurrentKey("Line No.");
                            InvtRecLineTbl.SetRange("Receipt No.", InvtDocHeaderTbl."No.");
                            InvtRecLineTbl.SetRange("Line No.", LineNo);
                            if InvtRecLineTbl.FindFirst() then begin
                                // Add output as object to array
                                PostedLine.Add('ProductName', InvtRecLineTbl.Description);
                                PostedLine.Add('SKU', InvtRecLineTbl."Item No.");
                                PostedLine.Add('SerialNos', SerialNumbers);
                            end;
                            PostedLines.Add(PostedLine);
                            Clear(PostedLine);
                        end;
                    end;

                    PostedReceipt.Add('InvtHeader', PostedHeaders);
                    PostedReceipt.Add('InvtLine', PostedLines);
                    PostedReceipts.Add(PostedReceipt);
                    Clear(PostedReceipt);
                end;
            end;
        end;
        exit(PostedReceipts);
    end;
}
