codeunit 70157 "Moo.Model.ItemTracking" implements "Moo.IModel"
{
    var
        No: Text;
        SerialNo: Text;
        ItemNo: Text;
        VariantCode: Text;
        Quantity: Decimal;
        SalesLine: Record "Sales Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ReservStatus: Enum "Reservation Status";

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
        exit('{\"message\":\"item tracking lines inserted successfully\"}');
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
        map(inputJson);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure map(jsonText: Text)
    var
        Token: JsonToken;
        JT: JsonToken;
        JO: JsonObject;
        Token2: JsonToken;
        Token3: JsonToken;
        SI_JO: JsonObject;
        JV: JsonValue;
        TempReservEntry: Record "Reservation Entry" temporary;
        HelperDomain: Codeunit "Moo.HelperDomain";
    begin
        Token.ReadFrom(jsonText);
        if Token.IsValue() then begin
            JV := Token.AsValue();
            Token2.ReadFrom(JV.AsText());
            JO := Token2.AsObject();
        end else
            JO := Token.AsObject();

        JO.Get('item_tracking', Token3);
        foreach JT in Token3.AsArray() do begin
            if JT.IsObject() then begin

                Evaluate(No, HelperDomain.GetFieldValue('No', JT.AsObject()));
                Evaluate(SerialNo, HelperDomain.GetFieldValue('SerialNo', JT.AsObject()));
                Evaluate(ItemNo, HelperDomain.GetFieldValue('ItemNo', JT.AsObject()));
                Evaluate(VariantCode, HelperDomain.GetFieldValue('VariantCode', JT.AsObject()));
                Evaluate(Quantity, HelperDomain.GetFieldValue('Quantity', JT.AsObject()));
                TempReservEntry.DeleteAll();
                TempReservEntry.Init();
                TempReservEntry."Entry No." += 1;
                TempReservEntry."Item No." := ItemNo;
                if VariantCode <> '0' then
                    TempReservEntry."Variant Code" := VariantCode;
                TempReservEntry."Serial No." := SerialNo;
                TempReservEntry.Quantity := Quantity;
                TempReservEntry."Expiration Date" := Today();
                TempReservEntry.Insert();
                insertItemTracking(TempReservEntry);
            end;
        end;
    end;


    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure insertItemTracking(TempReservEntry: Record "Reservation Entry" temporary)
    var
        _salesHeader: Record "Sales Header";
    begin
        if No = '' then
            exit;
        _salesHeader.SetRange("External Document No.", No);
        _salesHeader.SetRange("Document Type", _salesHeader."Document Type"::Invoice);
        if _salesHeader.FindFirst() then begin
            SalesLine.SetRange("Document Type", _salesHeader."Document Type");
            SalesLine.SetRange("Document No.", _salesHeader."No.");
            SalesLine.SetRange("No.", TempReservEntry."Item No.");
            if SalesLine.FindFirst() then begin
                CreateReservEntry.SetDates(0D, TempReservEntry."Expiration Date");
                CreateReservEntry.CreateReservEntryFor(
                  Database::"Sales Line", SalesLine."Document Type".AsInteger(),
                  SalesLine."Document No.", '', 0, SalesLine."Line No.", SalesLine."Qty. per Unit of Measure",
                  TempReservEntry.Quantity, TempReservEntry.Quantity * SalesLine."Qty. per Unit of Measure", TempReservEntry);
                CreateReservEntry.CreateEntry(
                  SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code", '', 0D, 0D, 0, ReservStatus::Surplus);
            end;
        end;
    end;
}
