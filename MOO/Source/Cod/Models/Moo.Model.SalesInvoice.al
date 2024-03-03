codeunit 70151 "Moo.Model.SalesInvoice" implements "Moo.IModel"
{
    var
        _salesHeader: Record "Sales Header";
        _salesLine: Record "Sales Line";
        No: Text;
        DocNo: Text;
        CustNo: Text;
        ItemNo: Text;
        VariantCode: Text;
        Quantity: Decimal;
        UnitofMeasureCode: Text;
        LineNo: Integer;
        SalesJArray: JsonArray;
        jsonString: Text;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
        //from BC to Json
        exit(FormatResponse(SalesJArray));
        // exit(jsonString);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
        //to BC

        //fromJsonHeader
        //fromJsonLine
        // map(inputJson);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJsonHeader(inputJson: Text; var _listOfInvoiceNos: List of [Text])
    begin
        //to BC
        Clear(_listOfInvoiceNos);
        mapHeader(inputJson, _listOfInvoiceNos);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJsonLine(inputJson: Text; _listOfInvoiceNos: List of [Text])
    begin
        //to BC
        mapLine(inputJson, _listOfInvoiceNos);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure mapHeader(jsonText: Text; var _listOfInvoiceNos: List of [Text])
    var
        Token: JsonToken;
        JT: JsonToken;
        JO: JsonObject;
        Token2: JsonToken;
        Token3: JsonToken;
        SI_JO: JsonObject;
        JV: JsonValue;
        HelperDomain: Codeunit "Moo.HelperDomain";
    begin
        Clear(_listOfInvoiceNos);
        Token.ReadFrom(jsonText);
        if Token.IsValue() then begin
            JV := Token.AsValue();
            Token2.ReadFrom(JV.AsText());
            JO := Token2.AsObject();
        end else
            JO := Token.AsObject();

        JO.Get('order_header', Token3);
        foreach JT in Token3.AsArray() do begin
            if JT.IsObject() then begin
                Evaluate(No, HelperDomain.GetFieldValue('No', JT.AsObject()));
                Evaluate(DocNo, HelperDomain.GetFieldValue('DocNo', JT.AsObject()));
                Evaluate(CustNo, HelperDomain.GetFieldValue('CustNo', JT.AsObject()));
                InsertSalesHeader(_salesHeader);
                _listOfInvoiceNos.Add(No);
                _listOfInvoiceNos.Add(_salesHeader."No.");
                Clear(SI_JO);
                SI_JO.Add('InvoiceNo', _salesHeader."No.");
                SI_JO.Add('ExternalDocNo', No);
                SalesJArray.Add(SI_JO);
            end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure mapLine(jsonText: Text; _listOfInvoiceNos: List of [Text])
    var
        Token: JsonToken;
        JT: JsonToken;
        JO: JsonObject;
        Token2: JsonToken;
        Token3: JsonToken;
        listOfKeys: List of [Text];
        JV: JsonValue;
        HelperDomain: Codeunit "Moo.HelperDomain";
    begin
        Token.ReadFrom(jsonText);
        if Token.IsValue() then begin
            JV := Token.AsValue();
            Token2.ReadFrom(JV.AsText());
            JO := Token2.AsObject();
        end else
            JO := Token.AsObject();

        JO.Get('order_line', Token3);
        foreach JT in Token3.AsArray() do begin
            if JT.IsObject() then begin
                if No <> HelperDomain.GetFieldValue('No', JT.AsObject()) then
                    Clear(LineNo);
                Evaluate(No, HelperDomain.GetFieldValue('No', JT.AsObject()));
                Clear(_salesHeader);
                _salesHeader.SetRange("Document Type", _salesHeader."Document Type"::Invoice);
                _salesHeader.SetRange("No.", _listOfInvoiceNos.Get(_listOfInvoiceNos.IndexOf(No) + 1));
                if _salesHeader.FindFirst() then begin
                    Evaluate(ItemNo, HelperDomain.GetFieldValue('ItemNo', JT.AsObject()));
                    Evaluate(VariantCode, HelperDomain.GetFieldValue('VariantCode', JT.AsObject()));
                    Evaluate(Quantity, HelperDomain.GetFieldValue('Quantity', JT.AsObject()));
                    Evaluate(UnitofMeasureCode, HelperDomain.GetFieldValue('UnitofMeasureCode', JT.AsObject()));
                    LineNo += 10000;
                    InsertSalesLine(_salesLine);
                end;
            end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure InsertSalesLine(var _salesLine: Record "Sales Line")
    begin
        Clear(_salesLine);
        _salesLine.Init();
        _salesLine.Validate("Document Type", _salesLine."Document Type"::Invoice);
        _salesLine.Validate("Document No.", _salesHeader."No.");
        _salesLine.Validate("Line No.", LineNo);
        _salesLine.Validate(Type, _salesLine.Type::Item);
        _salesLine.Validate("No.", ItemNo);
        if VariantCode <> '0' then
            _salesLine.Validate("Variant Code", VariantCode);
        _salesLine.Validate(Quantity, Quantity);
        _salesLine.Insert(true);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure InsertSalesHeader(var _salesHeader: Record "Sales Header")
    begin
        Clear(_salesHeader);
        _salesHeader.Init();
        _salesHeader.Validate("Document Type", _salesHeader."Document Type"::Invoice);
        _salesHeader.Validate("No. Series");
        _salesHeader.Validate("No.");
        _salesHeader.Validate("Sell-to Customer No.", CustNo);
        _salesHeader.Validate("Bill-to Customer No.", CustNo);
        _salesHeader.Validate("Posting Date", Today);
        _salesHeader.Validate("Document Date", Today);
        _salesHeader.Validate("External Document No.", No);
        _salesHeader.Insert(true);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure FormatResponse(JArray: JsonArray): Text
    var
        JArrayText: Text;
    begin
        JArray.WriteTo(JArrayText);
        exit(JArrayText);
    end;

}
