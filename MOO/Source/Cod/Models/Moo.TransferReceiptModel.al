codeunit 70420 "Moo.TransferReceiptModel" implements "Moo.IModel"
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
    procedure MapToJson(TransferOrderNo: Text): JsonArray;
    var
        TransferHeader: Record "Transfer Header";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        HelperDomain: Codeunit "Moo.HelperDomain";
        PostTransferReceipt: Codeunit "TransferOrder-Post Receipt";
        JSONDocs: JsonArray;
        JSONDoc: JsonObject;
        JSONHeader: JsonObject;
        JSONLines: JsonArray;
        JSONLine: JsonObject;
        JSONTrackingLine: JsonObject;
        JSONTrackingLines: JsonArray;
        EntryType: Enum "Item Ledger Entry Type";
        DocType: Enum "Item Ledger Document Type";
    begin
        // Find and map Transfer Shipment Header
        TransferHeader.Reset();
        TransferHeader.SetRange("No.", TransferOrderNo);
        if TransferHeader.FindFirst() then begin
            // Post Tranfer Receipt
            PostTransferReceipt.Run(TransferHeader);

            // Find and map Transfer Shipment Header
            TransferReceiptHeader.Reset();
            TransferReceiptHeader.SetRange("Transfer Order No.", TransferOrderNo);
            if TransferReceiptHeader.FindSet() then begin
                repeat
                    // Map current Transfer Shipment Header record to JSON
                    JSONHeader := HelperDomain.Rec2Json(TransferReceiptHeader);

                    // Find and map Document Line
                    TransferReceiptLine.Reset();
                    TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
                    if TransferReceiptLine.FindSet() then begin
                        repeat
                            // Map current Invt. Document Line record to JSON
                            JSONLine := HelperDomain.Rec2Json(TransferReceiptLine);

                            // Find and map Document Trackling Line
                            ItemLedgerEntry.Reset();
                            ItemLedgerEntry.SetRange("Item No.", TransferReceiptLine."Item No.");
                            ItemLedgerEntry.SetRange("Variant Code", TransferReceiptLine."Variant Code");
                            ItemLedgerEntry.SetRange("Document No.", TransferReceiptLine."Document No.");
                            ItemLedgerEntry.SetRange("Entry Type", EntryType::Transfer);
                            ItemLedgerEntry.SetRange("Document Line No.", TransferReceiptLine."Line No.");
                            ItemLedgerEntry.SetRange("Document Type", DocType::"Transfer Receipt");
                            ItemLedgerEntry.SetRange("Location Code", TransferReceiptLine."Transfer-to Code");
                            if ItemLedgerEntry.FindSet() then begin
                                repeat
                                    // Map current Item Tracking Line record to JSON
                                    JSONTrackingLine := HelperDomain.Rec2Json(ItemLedgerEntry);
                                    JSONTrackingLines.Add(JSONTrackingLine);
                                    Clear(JSONTrackingLine);
                                until ItemLedgerEntry.Next() = 0;
                            end;

                            JSONLine.Add('ItemTrackingLines', JSONTrackingLines);
                            JSONLines.Add(JSONLine);
                            Clear(JSONTrackingLines);
                            Clear(JSONLine);
                        until TransferReceiptLine.Next() = 0;
                    end;
                    JSONHeader.Add('TransferReceiptLines', JSONLines);
                    JSONDoc.Add('TransferReceiptHeader', JSONHeader);

                    JSONDocs.Add(JSONDoc);
                    Clear(JSONLines);
                    Clear(JSONHeader);
                    Clear(JSONDoc);
                until TransferReceiptHeader.Next() = 0;
            end;
        end;
        exit(JSONDocs);
    end;
}