codeunit 70419 "Moo.TransferShipmentModel" implements "Moo.IModel"
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
    procedure MapToJson(LocationCode: Text): JsonArray;
    var
        TransferShipHeader: Record "Transfer Shipment Header";
        TransferShipLine: Record "Transfer Shipment Line";
        TransferHeader: Record "Transfer Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        HelperDomain: Codeunit "Moo.HelperDomain";
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
        TransferShipHeader.Reset();
        TransferShipHeader.SetRange("Transfer-to Code", LocationCode);
        if TransferShipHeader.FindSet() then begin
            repeat
                TransferHeader.Reset();
                TransferHeader.SetRange("No.", TransferShipHeader."Transfer Order No.");
                if TransferHeader.FindFirst() then begin
                    // Map current Transfer Shipment Header record to JSON
                    JSONHeader := HelperDomain.Rec2Json(TransferShipHeader);

                    // Find and map Document Line
                    TransferShipLine.Reset();
                    TransferShipLine.SetRange("Document No.", TransferShipHeader."No.");
                    if TransferShipLine.FindSet() then begin
                        repeat
                            // Map current Invt. Document Line record to JSON
                            JSONLine := HelperDomain.Rec2Json(TransferShipLine);

                            // Find and map Document Trackling Line
                            ItemLedgerEntry.Reset();
                            ItemLedgerEntry.SetRange("Item No.", TransferShipLine."Item No.");
                            ItemLedgerEntry.SetRange("Variant Code", TransferShipLine."Variant Code");
                            ItemLedgerEntry.SetRange("Document No.", TransferShipLine."Document No.");
                            ItemLedgerEntry.SetRange("Entry Type", EntryType::Transfer);
                            ItemLedgerEntry.SetRange("Document Line No.", TransferShipLine."Line No.");
                            ItemLedgerEntry.SetRange("Document Type", DocType::"Transfer Shipment");
                            ItemLedgerEntry.SetRange("Location Code", TransferShipLine."Transfer-from Code");
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
                        until TransferShipLine.Next() = 0;
                    end;
                    JSONHeader.Add('TransferShipmentLines', JSONLines);
                    JSONDoc.Add('TransferShipmentHeader', JSONHeader);

                    JSONDocs.Add(JSONDoc);
                    Clear(JSONLines);
                    Clear(JSONHeader);
                    Clear(JSONDoc);
                end;
            until TransferShipHeader.Next() = 0;
        end;
        exit(JSONDocs);
    end;
}