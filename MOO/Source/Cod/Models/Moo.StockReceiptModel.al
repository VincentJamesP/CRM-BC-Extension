codeunit 70411 "Moo.StockReceiptModel" implements "Moo.IModel"
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
    procedure InsertInvtDocHeader(SourceData: JsonObject): Record "Invt. Document Header";
    var
        ProductLocation: Text;
        ProductPostingDate: Date;
        ProductDocumentDate: Date;
        ExternalDocNo: Text;
        HelperDomain: Codeunit "Moo.HelperDomain";
        invtDocHeader: Record "Invt. Document Header";
        Test: Text;
    begin
        // Assign Source Data to Local Parameters
        Evaluate(ProductLocation, HelperDomain.GetFieldValue('location', SourceData));
        Evaluate(ProductPostingDate, HelperDomain.GetFieldValue('posting_date', SourceData));
        Evaluate(ProductDocumentDate, HelperDomain.GetFieldValue('document_date', SourceData));
        Evaluate(ExternalDocNo, HelperDomain.GetFieldValue('external_doc_no', SourceData));

        // Insert source data to Invt. Document Header Table
        invtDocHeader.Init();
        invtDocHeader.Validate("Location Code", ProductLocation);
        invtDocHeader.Validate("Document Type", invtDocHeader."Document Type"::Receipt);
        invtDocHeader.Validate("Posting Date", ProductPostingDate);
        invtDocHeader.Validate("Document Date", ProductDocumentDate);
        invtDocHeader.Validate("External Document No.", ExternalDocNo);
        invtDocHeader.Insert(true);
        exit(invtDocHeader);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure InsertInvtDocLine(SourceData: JsonObject; LineNo: Integer; invtDocHeader: Record "Invt. Document Header"): Text;
    var
        ProductSKU: Text;
        ProductQuantity: Decimal;
        ProductVariant: Text;
        HelperDomain: Codeunit "Moo.HelperDomain";
        invtDocLine: Record "Invt. Document Line";
        ProductLocation: Text;
    begin
        // Assign Source Data to Local Parameters
        Evaluate(ProductSKU, HelperDomain.GetFieldValue('sku', SourceData));
        Evaluate(ProductQuantity, HelperDomain.GetFieldValue('quantity', SourceData));
        Evaluate(ProductVariant, HelperDomain.GetFieldValue('variantcode', SourceData));

        // Insert source data to Invt. Document Line Table
        invtDocLine.Init();
        invtDocLine.Validate("Document No.", invtDocHeader."No.");
        invtDocLine.Validate("Document Type", invtDocLine."Document Type"::Receipt);
        invtDocLine.Validate("Line No.", LineNo);
        invtDocLine.Validate("Item No.", ProductSKU);
        invtDocLine.Validate(Quantity, ProductQuantity);
        invtDocLine.Validate("Posting Date", invtDocHeader."Posting Date");
        invtDocLine.Validate("Document Date", invtDocHeader."Document Date");
        if ProductVariant <> '0' then begin
            invtDocLine.Validate("Variant Code", ProductVariant);
        end;
        invtDocLine.Insert(true);
        exit(ProductSKU);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure InsertItemTrackingLines(SerialNumber: JsonObject; LineNo: Integer; DocNo: Text)
    var
        TempReservEntry: Record "Reservation Entry" temporary;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        InvtDocLine: Record "Invt. Document Line";
        ReservStatus: Enum "Reservation Status";
        DocType: Enum "Invt. Doc. Document Type";
        HelperDomain: Codeunit "Moo.HelperDomain";
        SerialNo: Text;
    begin
        // Assign Source Data to Local Parameters 
        Evaluate(SerialNo, HelperDomain.GetFieldValue('serialnumber', SerialNumber));

        // Set Filter for inserted Invt. Document Header and Lines
        InvtDocLine.Reset();
        InvtDocLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        InvtDocLine.SetRange("Document Type", DocType::Receipt);
        InvtDocLine.SetRange("Document No.", DocNo);
        InvtDocLine.SetRange("Line No.", LineNo);

        // Create Reservation Entry for entering Serial No. on Item Tracking Lines
        if InvtDocLine.FindFirst() then begin
            TempReservEntry.DeleteAll();
            TempReservEntry.Init();
            TempReservEntry."Serial No." := SerialNo;
            TempReservEntry.Quantity := 1;
            TempReservEntry."Quantity (Base)" := 1;
            TempReservEntry."Expiration Date" := Today();
            TempReservEntry.Insert();
            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Invt. Document Line",
              InvtDocLine."Document Type".AsInteger(), InvtDocLine."Document No.", '',
              0, InvtDocLine."Line No.", InvtDocLine."Qty. per Unit of Measure",
              TempReservEntry.Quantity, TempReservEntry."Quantity (Base)", TempReservEntry);
            CreateReservEntry.CreateEntry(
                InvtDocLine."Item No.", InvtDocLine."Variant Code", InvtDocLine."Location Code",
                '', 0D, 0D, 0, ReservStatus::Surplus);
        end;
    end;
}