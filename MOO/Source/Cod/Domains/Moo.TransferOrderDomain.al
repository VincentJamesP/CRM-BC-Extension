codeunit 70177 "Moo.TransferOrderDomain" implements "Moo.IDomain"
{
    var
        ErrText: TextConst ENU = 'Product quantity and count of serial numbers provided must be equal.';

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(sourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        sourceData: JsonArray;
        responseData: JsonArray;
        PostedTransferReceipts: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := PostTransferShipmentPostTransferReceipt(sourceData);
        responseData.WriteTo(PostedTransferReceipts);
        exit(PostedTransferReceipts);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(sourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        sourceData: JsonArray;
        responseData: JsonArray;
        TransferOrders: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := GetTransferOrdersByOrigin(sourceData);
        responseData.WriteTo(TransferOrders);
        exit(TransferOrders);
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
    local procedure GetTransferOrdersByOrigin(SourceData: JsonArray): JsonArray;
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferOrderModel: Codeunit "Moo.TransferOrderModel";
        LoopToken: JsonToken;
        ResultsArr: JsonArray;
        ProductOrigin: Text;
        ProductReference: Text;
        HelperModel: Codeunit "Moo.HelperModel";
    begin
        foreach LoopToken in SourceData do begin
            if LoopToken.IsObject() then begin
                Evaluate(ProductOrigin, HelperDomain.GetFieldValue('Store', LoopToken.AsObject()));
                Evaluate(ProductReference, HelperDomain.GetFieldValue('ReferenceCode', LoopToken.AsObject()));
                if ResultsArr.Count() <> 0 then begin
                    Clear(ResultsArr);
                end;
                ResultsArr := TransferOrderModel.MapToJson(ProductOrigin, ProductReference);
            end;
        end;
        exit(ResultsArr);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure PostTransferShipmentPostTransferReceipt(SourceData: JsonArray): JsonArray;
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferOrderModel: Codeunit "Moo.TransferOrderModel";
        TransferHeader: Record "Transfer Header";
        TempLineNo: Integer;
        InvtShipNo: Text;
        Destination: Text;
        TransferLines: JsonArray;
        LineNo: Integer;
        LineObj: JsonObject;
        LineArray: JsonArray;
        ProductSKU: Text;
        ProductSerials: JsonArray;
        LoopToken: JsonToken;
        JsonObj: JsonObject;
        JsonArr: JsonArray;
        ResultsArr: JsonArray;
        TransferOrderNo: Text;
        LineToken: JsonToken;
        SerialNumToken: JsonToken;
        ProductQty: Integer;
        HelperModel: Codeunit "Moo.HelperModel";
    begin
        foreach LoopToken in SourceData do begin
            if LoopToken.IsObject() then begin
                // Clear Result Array
                if ResultsArr.Count() <> 0 then
                    Clear(ResultsArr);

                Evaluate(TransferOrderNo, HelperDomain.GetFieldValue('TransferOrderNo', LoopToken.AsObject()));
                // Check if there Transfer Order No. passed modify/insert new lines
                // else create new Transfer Order
                If TransferOrderNo <> '' then begin
                    TransferHeader.Reset();
                    TransferHeader.SetRange("No.", TransferOrderNo);
                    if TransferHeader.FindFirst() then begin
                        TransferLines := HelperDomain.GetArrayValues('Lines', LoopToken.AsObject());
                        // Insert/Modify Transfer Line/s
                        foreach LineToken in TransferLines do begin
                            if LineToken.IsObject() then begin
                                Evaluate(TempLineNo, HelperDomain.GetFieldValue('LineNo', LineToken.AsObject()));
                                if TempLineNo <> 0 then begin
                                    LineNo := TempLineNo;
                                    TransferOrderModel.ModifyTransferLine(LineToken.AsObject(), LineNo, TransferHeader);
                                end else begin
                                    LineNo := GetLastLineNo(TransferOrderNo) + 10000;
                                    TransferOrderModel.InsertTransferLine(LineToken.AsObject(), LineNo, TransferHeader);
                                end;

                                // Assign Source Data to Local Parameters 
                                ProductSerials := HelperDomain.GetArrayValues('SerialNumbers', LineToken.AsObject());
                                Evaluate(ProductQty, HelperDomain.GetFieldValue('Quantity', LineToken.AsObject()));

                                If ProductSerials.Count() = ProductQty then begin
                                    // Loop through the serial numbers based on quantity
                                    foreach SerialNumToken in ProductSerials do begin
                                        if SerialNumToken.IsObject() then begin
                                            if TempLineNo <> 0 then begin
                                                TransferOrderModel.ModifyItemTrackingLines(SerialNumToken.AsObject(), LineNo, TransferHeader."No.");
                                            end else begin
                                                TransferOrderModel.InsertItemTrackingLines(SerialNumToken.AsObject(), LineNo, TransferHeader."No.");
                                            end;
                                        end;
                                    end;
                                end else begin
                                    Error(ErrText);
                                end;

                                // Clear variable data
                                Clear(ProductSerials);
                                Clear(LineObj);
                            end;
                        end;
                    end;

                    // Insert comments
                    TransferOrderModel.InsertCommentLine(TransferHeader."No.", LoopToken.AsObject());

                    // Add output as object to array
                    ResultsArr.Add(TransferOrderModel.PostToJson(TransferOrderNo));
                end else begin
                    // Insert Transfer Header
                    TransferHeader := TransferOrderModel.InsertTransferHeader(LoopToken.AsObject());
                    TransferLines := HelperDomain.GetArrayValues('Lines', LoopToken.AsObject());

                    // Insert Transfer Line/s
                    foreach LineToken in TransferLines do begin
                        if LineToken.IsObject() then begin
                            LineNo += 10000;
                            ProductSKU := TransferOrderModel.InsertTransferLine(LineToken.AsObject(), LineNo, TransferHeader);

                            // Assign Source Data to Local Parameters 
                            ProductSerials := HelperDomain.GetArrayValues('SerialNumbers', LineToken.AsObject());
                            Evaluate(ProductQty, HelperDomain.GetFieldValue('Quantity', LineToken.AsObject()));

                            If ProductSerials.Count() = ProductQty then begin
                                // Loop through the serial numbers based on quantity
                                foreach SerialNumToken in ProductSerials do begin
                                    if SerialNumToken.IsObject() then begin
                                        TransferOrderModel.InsertItemTrackingLines(SerialNumToken.AsObject(), LineNo, TransferHeader."No.");
                                    end;
                                end;
                            end else begin
                                Error(ErrText);
                            end;

                            // Clear variable data
                            Clear(ProductSerials);
                            Clear(LineObj);
                        end;
                    end;

                    // Insert comments
                    TransferOrderModel.InsertCommentLine(TransferHeader."No.", LoopToken.AsObject());

                    // Add output as object to array
                    ResultsArr.Add(TransferOrderModel.PostToJson(TransferHeader."No."));

                    // Clear variable data
                    Clear(LineNo);
                end;
            end;
        end;
        exit(ResultsArr);
    end;

    local procedure GetLastLineNo(TransferOrderNo: Text): Integer
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", TransferOrderNo);
        TransferLine.SetAscending("Line No.", false);
        if TransferLine.FindFirst() then
            exit(TransferLine."Line No.");
    end;
}
