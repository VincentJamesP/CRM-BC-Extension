codeunit 70422 "Moo.TransferOrderModel" implements "Moo.IModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure MapToJson(ProductOrigin: Text; RefCode: Text): JsonArray;
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ReservationEntry: Record "Reservation Entry";
        HelperDomain: Codeunit "Moo.HelperDomain";
        InvtCommentLine: Record "Inventory Comment Line";
        JSONDocs: JsonArray;
        JSONDoc: JsonObject;
        JSONHeader: JsonObject;
        JSONLines: JsonArray;
        JSONLine: JsonObject;
        JSONTrackingLine: JsonObject;
        JSONTrackingLines: JsonArray;
        DocType: Enum "Inventory Comment Document Type";
        MovementType: Text;
    begin
        // Find and map Transfer Header
        TransferHeader.Reset();
        TransferHeader.SetRange("Transfer-from Code", ProductOrigin);
        if TransferHeader.FindSet() then begin
            repeat
                // Check comment line of current Transfer Order if it matches the
                // RefCode parameter
                InvtCommentLine.Reset();
                InvtCommentLine.SetRange("Document Type", DocType::"Transfer Order");
                InvtCommentLine.SetRange("No.", TransferHeader."No.");
                if InvtCommentLine.FindSet() then begin
                    repeat
                        MovementType := InvtCommentLine.Comment.ToLower();
                        if (MovementType = RefCode.ToLower()) OR (MovementType.Contains(RefCode.ToLower())) then begin
                            // Map current Transfer Header record to JSON
                            JSONHeader := HelperDomain.Rec2Json(TransferHeader);

                            // Find and map Document Line
                            TransferLine.Reset();
                            TransferLine.SetRange("Document No.", TransferHeader."No.");
                            TransferLine.SetRange("Transfer-from Code", ProductOrigin);
                            if TransferLine.FindSet() then begin
                                repeat
                                    // Map current Invt. Document Line record to JSON
                                    JSONLine := HelperDomain.Rec2Json(TransferLine);

                                    // Find and map Document Trackling Line
                                    ReservationEntry.Reset();
                                    ReservationEntry.SetRange("Source ID", TransferLine."Document No.");
                                    ReservationEntry.SetRange("Item No.", TransferLine."Item No.");
                                    ReservationEntry.SetRange("Variant Code", TransferLine."Variant Code");
                                    ReservationEntry.SetRange("Source Type", DATABASE::"Transfer Line");
                                    ReservationEntry.SetRange("Location Code", TransferLine."Transfer-to Code");
                                    if ReservationEntry.FindSet() then begin
                                        repeat
                                            // Map current Item Tracking Line record to JSON
                                            JSONTrackingLine := HelperDomain.Rec2Json(ReservationEntry);
                                            JSONTrackingLines.Add(JSONTrackingLine);
                                            Clear(JSONTrackingLine);
                                        until ReservationEntry.Next() = 0;
                                    end;

                                    JSONLine.Add('ItemTrackingLines', JSONTrackingLines);
                                    JSONLines.Add(JSONLine);
                                    Clear(JSONTrackingLines);
                                    Clear(JSONLine);
                                until TransferLine.Next() = 0;
                            end;
                            JSONHeader.Add('TransferLines', JSONLines);
                            JSONDoc.Add('TransferHeader', JSONHeader);

                            JSONDocs.Add(JSONDoc);
                            Clear(JSONLines);
                            Clear(JSONHeader);
                            Clear(JSONDoc);
                            Break;
                        end;
                    until InvtCommentLine.Next() = 0;
                end;
            until TransferHeader.Next() = 0;
        end;
        exit(JSONDocs);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure InsertTransferHeader(SourceData: JsonObject): Record "Transfer Header";
    var
        TransferFrom: Text;
        TransferTo: Text;
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferHeader: Record "Transfer Header";
        Location: Record Location;
    begin
        // Assign Source Data to Local Parameters
        Evaluate(TransferFrom, HelperDomain.GetFieldValue('TransferFrom', SourceData));
        Evaluate(TransferTo, HelperDomain.GetFieldValue('TransferTo', SourceData));

        // Insert source data to Invt. Document Header Table
        TransferHeader.Init();
        TransferHeader.Validate("Transfer-from Code", TransferFrom);
        TransferHeader.Validate("Transfer-to Code", TransferTo);
        Location.Reset();
        Location.SetRange("Use As In-Transit", true);
        if Location.FindFirst() then
            TransferHeader.Validate("In-Transit Code", Location.Code);
        TransferHeader.Insert(true);
        exit(TransferHeader);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure InsertTransferLine(SourceData: JsonObject; LineNo: Integer; TransferHeader: Record "Transfer Header"): Text;
    var
        ProductSKU: Text;
        ProductQuantity: Decimal;
        ProductVariant: Text;
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferLine: Record "Transfer Line";
    begin
        // Assign Source Data to Local Parameters
        Evaluate(ProductSKU, HelperDomain.GetFieldValue('SKU', SourceData));
        Evaluate(ProductQuantity, HelperDomain.GetFieldValue('Quantity', SourceData));
        Evaluate(ProductVariant, HelperDomain.GetFieldValue('VariantCode', SourceData));

        // Insert source data to Transfer Line Table
        TransferLine.Init();
        TransferLine.Validate("Document No.", TransferHeader."No.");
        TransferLine.Validate("Line No.", LineNo);
        TransferLine.Validate("Item No.", ProductSKU);
        if ProductVariant <> '0' then
            TransferLine.Validate("Variant Code", ProductVariant);
        TransferLine.Validate(Quantity, ProductQuantity);
        TransferLine.Insert(true);
        exit(ProductSKU);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ModifyTransferLine(SourceData: JsonObject; LineNo: Integer; TransferHeader: Record "Transfer Header"): Text;
    var
        ProductSKU: Text;
        ProductQuantity: Decimal;
        ProductVariant: Text;
        HelperDomain: Codeunit "Moo.HelperDomain";
        TransferLine: Record "Transfer Line";
    begin
        // Assign Source Data to Local Parameters
        Evaluate(ProductSKU, HelperDomain.GetFieldValue('SKU', SourceData));
        Evaluate(ProductQuantity, HelperDomain.GetFieldValue('Quantity', SourceData));
        Evaluate(ProductVariant, HelperDomain.GetFieldValue('VariantCode', SourceData));

        // Check if line details match the current transfer line
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Line No.", LineNo);
        TransferLine.SetRange("Item No.", ProductSKU);
        if ProductVariant <> '0' then
            TransferLine.SetRange("Variant Code", ProductVariant);
        TransferLine.SetRange(Quantity, ProductQuantity);
        If Not TransferLine.FindFirst() then begin
            TransferLine.SetRange(Quantity);
            If TransferLine.FindFirst() then begin
                TransferLine.Validate(Quantity, ProductQuantity);
                TransferLine.Modify(true);
            end;
        end;
        exit(ProductSKU);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure InsertItemTrackingLines(SerialNumber: JsonObject; LineNo: Integer; DocNo: Text)
    var
        TempReservEntry: Record "Reservation Entry" temporary;
        TransferLine: Record "Transfer Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ReservStatus: Enum "Reservation Status";
        CurrentSourceRowID: Text[250];
        SecondSourceRowID: Text[250];
        HelperDomain: Codeunit "Moo.HelperDomain";
        SerialNo: Text;
    begin
        // Assign Source Data to Local Parameters 
        Evaluate(SerialNo, HelperDomain.GetFieldValue('serialnumber', SerialNumber));

        // Set Filter for inserted Invt. Document Header and Lines
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", DocNo);
        TransferLine.SetRange("Line No.", LineNo);

        // Create Reservation Entry for entering Serial No. on Item Tracking Lines
        if TransferLine.FindFirst() then begin
            // Transfer To Entry
            TempReservEntry.DeleteAll();
            TempReservEntry.Init();
            TempReservEntry."Serial No." := SerialNo;
            TempReservEntry.Quantity := 1;
            TempReservEntry."Quantity (Base)" := 1;
            TempReservEntry."Expiration Date" := Today();
            TempReservEntry.Insert();
            CreateReservEntry.SetDates(0D, TempReservEntry."Expiration Date");
            CreateReservEntry.CreateReservEntryFor(
                Database::"Transfer Line", 0,
                TransferLine."Document No.", '', TransferLine."Derived From Line No.", TransferLine."Line No.", TransferLine."Qty. per Unit of Measure",
                TempReservEntry.Quantity, TempReservEntry.Quantity * TransferLine."Qty. per Unit of Measure", TempReservEntry);
            CreateReservEntry.CreateEntry(
                TransferLine."Item No.", TransferLine."Variant Code", TransferLine."Transfer-from Code", '', TransferLine."Receipt Date", 0D, 0, ReservStatus::Surplus);

            CurrentSourceRowID := ItemTrackingMgt.ComposeRowID(5741, 0, TransferLine."Document No.", '', 0, TransferLine."Line No.");

            SecondSourceRowID := ItemTrackingMgt.ComposeRowID(5741, 1, TransferLine."Document No.", '', 0, TransferLine."Line No.");

            ItemTrackingMgt.SynchronizeItemTracking(CurrentSourceRowID, SecondSourceRowID, '');
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ModifyItemTrackingLines(SerialNumber: JsonObject; LineNo: Integer; DocNo: Text)
    var
        TransferLine: Record "Transfer Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ReservStatus: Enum "Reservation Status";
        CurrentSourceRowID: Text[250];
        SecondSourceRowID: Text[250];
        HelperDomain: Codeunit "Moo.HelperDomain";
        ReservationEntry: Record "Reservation Entry";
        SerialNo: Text;
    begin
        // Assign Source Data to Local Parameters 
        Evaluate(SerialNo, HelperDomain.GetFieldValue('serialnumber', SerialNumber));

        // Set Filter for inserted Invt. Document Header and Lines
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", DocNo);
        TransferLine.SetRange("Line No.", LineNo);

        // Create Reservation Entry for entering Serial No. on Item Tracking Lines
        if TransferLine.FindFirst() then begin
            // Find and map Document Trackling Line
            ReservationEntry.Reset();
            ReservationEntry.SetRange("Source ID", TransferLine."Document No.");
            ReservationEntry.SetRange("Item No.", TransferLine."Item No.");
            ReservationEntry.SetRange("Variant Code", TransferLine."Variant Code");
            ReservationEntry.SetRange("Source Type", DATABASE::"Transfer Line");
            ReservationEntry.SetRange("Serial No.", SerialNo);
            // Check if serial number is the same as existing
            if Not ReservationEntry.FindSet() then begin
                ReservationEntry.SetRange("Serial No.");
                // If not existing then update serial numbers
                If ReservationEntry.FindSet() then begin
                    repeat
                        ReservationEntry.Validate("Serial No.", SerialNo);
                        ReservationEntry.Modify(true);
                    until ReservationEntry.Next() = 0;
                end;
            end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure InsertCommentLine(TransferOrderNo: Text; SourceData: JsonObject)
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        InvtCommentLine: Record "Inventory Comment Line";
        InvtShipNo: Text;
        Destination: Text;
        InvtShipComment: Text;
        DestinationComment: Text;
    begin
        // Assign Source Data to Local Parameters
        Evaluate(InvtShipNo, HelperDomain.GetFieldValue('InvtShipNo', SourceData));
        Evaluate(Destination, HelperDomain.GetFieldValue('Destination', SourceData));
        InvtShipComment := StrSubstNo('Inventory Shipment: %1', InvtShipNo);
        DestinationComment := StrSubstNo('Destination: %1', Destination);

        // Insert Inventory Shipment No. comment to Invt. Comment Line Table
        InvtCommentLine.Init();
        InvtCommentLine.Validate("Document Type", InvtCommentLine."Document Type"::"Transfer Order");
        InvtCommentLine.Validate("No.", TransferOrderNo);
        InvtCommentLine.Validate(Date, Today());
        InvtCommentLine.Validate("Line No.", GetLastLineNo(TransferOrderNo) + 10000);
        InvtCommentLine.Validate(Comment, InvtShipComment);
        InvtCommentLine.Insert(true);

        // Insert Inventory Shipment No. comment to Invt. Comment Line Table
        InvtCommentLine.Init();
        InvtCommentLine.Validate("Document Type", InvtCommentLine."Document Type"::"Transfer Order");
        InvtCommentLine.Validate("No.", TransferOrderNo);
        InvtCommentLine.Validate(Date, Today());
        InvtCommentLine.Validate("Line No.", GetLastLineNo(TransferOrderNo) + 10000);
        InvtCommentLine.Validate(Comment, DestinationComment);
        InvtCommentLine.Insert(true);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure PostToJson(TransferOrderNo: Text): JsonObject;
    var
        TransferHeader: Record "Transfer Header";
        PostTransferShipment: Codeunit "TransferOrder-Post Shipment";
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
        PostWhseReceipt: Codeunit "Whse.-Post Receipt";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        SourceDocType: Enum "Warehouse Activity Source Document";
        JSONDoc: JsonObject;
        TransferLine: Record "Transfer Line";
        HelperDomain: Codeunit "Moo.HelperDomain";
        ReservationEntry: Record "Reservation Entry";
    begin
        // Find and map Transfer Shipment Header
        TransferHeader.Reset();
        TransferHeader.SetRange("No.", TransferOrderNo);
        if TransferHeader.FindFirst() then begin
            // Post Tranfer Shipment
            PostTransferShipment.Run(TransferHeader);
            // Create Warehouse Receipt
            GetSourceDocInbound.CreateFromInbndTransferOrderHideDialog(TransferHeader);

            // Find and Map Created Warehouse Receipt Lines
            WarehouseReceiptLine.Reset();
            WarehouseReceiptLine.SetRange("Source No.", TransferHeader."No.");
            WarehouseReceiptLine.SetRange("Source Document", SourceDocType::"Inbound Transfer");
            if WarehouseReceiptLine.FindFirst() then begin
                // Add Warehouse Receipt No to output
                JSONDoc.Add('WarehouseReceiptNo', WarehouseReceiptLine."No.");
            end;
        end;
        exit(JSONDoc);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetLastLineNo(TransferOrderNo: Text): Integer
    var
        InvtCommentLine: Record "Inventory Comment Line";
    begin
        InvtCommentLine.Reset();
        InvtCommentLine.SetRange("No.", TransferOrderNo);
        InvtCommentLine.SetRange("Document Type", InvtCommentLine."Document Type"::"Transfer Order");
        InvtCommentLine.SetAscending("Line No.", false);
        if InvtCommentLine.FindFirst() then
            exit(InvtCommentLine."Line No.");
    end;
}