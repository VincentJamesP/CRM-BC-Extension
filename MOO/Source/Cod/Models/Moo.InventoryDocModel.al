codeunit 70415 "Moo.InventoryDocModel" implements "Moo.IModel"
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
    procedure MapToJson(DocType: Enum "Invt. Doc. Document Type"; LocationCode: Text): JsonArray;
    var
        InvtDocHeader: Record "Invt. Document Header";
        InvtDocLine: Record "Invt. Document Line";
        ReservationEntry: Record "Reservation Entry";
        HelperDomain: Codeunit "Moo.HelperDomain";
        JSONDocs: JsonArray;
        JSONDoc: JsonObject;
        JSONHeader: JsonObject;
        JSONLines: JsonArray;
        JSONLine: JsonObject;
        JSONTrackingLine: JsonObject;
        JSONTrackingLines: JsonArray;
    begin
        // Find and map Document Header
        InvtDocHeader.Reset();
        InvtDocHeader.SetRange("Document Type", DocType);
        InvtDocHeader.SetRange("Location Code", LocationCode);
        if InvtDocHeader.FindSet() then begin
            repeat
                // Map current Invt. Document Header record to JSON
                JSONHeader := HelperDomain.Rec2Json(InvtDocHeader);

                // Find and map Document Line
                InvtDocLine.Reset();
                InvtDocLine.SetRange("Document Type", DocType);
                InvtDocLine.SetRange("Document No.", InvtDocHeader."No.");
                if InvtDocLine.FindSet() then begin
                    repeat
                        // Map current Invt. Document Line record to JSON
                        JSONLine := HelperDomain.Rec2Json(InvtDocLine);

                        // Find and map Document Trackling Line
                        ReservationEntry.Reset();
                        ReservationEntry.SetRange("Source ID", InvtDocLine."Document No.");
                        ReservationEntry.SetRange("Item No.", InvtDocLine."Item No.");
                        ReservationEntry.SetRange("Variant Code", InvtDocLine."Variant Code");
                        ReservationEntry.SetRange("Source Type", DATABASE::"Invt. Document Line");
                        ReservationEntry.SetRange("Source Subtype", InvtDocLine."Document Type");
                        if ReservationEntry.FindSet() then begin
                            repeat
                                // Map current Item Tracking Line record to JSON
                                JSONTrackingLine := HelperDomain.Rec2Json(ReservationEntry);
                                JSONTrackingLines.Add(JSONTrackingLine);
                                Clear(JSONTrackingLine);
                            until ReservationEntry.Next() = 0;
                        end;

                        JSONLine.Add('TrackingLines', JSONTrackingLines);
                        JSONLines.Add(JSONLine);
                        Clear(JSONTrackingLines);
                        Clear(JSONLine);
                    until InvtDocLine.Next() = 0;
                end;
                JSONHeader.Add('DocumentLines', JSONLines);
                JSONDoc.Add('DocumentHeader', JSONHeader);

                JSONDocs.Add(JSONDoc);
                Clear(JSONLines);
                Clear(JSONHeader);
                Clear(JSONDoc);
            until InvtDocHeader.Next() = 0;
        end;
        exit(JSONDocs);
    end;
}