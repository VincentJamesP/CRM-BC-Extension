codeunit 70160 "Moo.Model.SalesOrder" implements "Moo.IModel"
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
        kti_sourcesalesorderid: Text;
        kti_sourcesalesorderitemid: Text;
        LocationCode: Text;
        customername: Text;
        address: Text;
        address2: Text;
        city: Text;
        postcode: Text;
        country: Text;
        contactno: Text;
        phoneno: Text;
        email: Text;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
        exit(FormatResponse(SalesJArray));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJsonHeader(inputJson: Text; var _listOfOrderNos: List of [Text])
    begin
        //to BC
        Clear(_listOfOrderNos);
        mapHeader(inputJson, _listOfOrderNos);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJsonLine(inputJson: Text; _listOfOrderNos: List of [Text])
    begin
        //to BC
        mapLine(inputJson, _listOfOrderNos);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure mapHeader(jsonText: Text; var _listOfOrderNos: List of [Text])
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
        Clear(_listOfOrderNos);
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
                Evaluate(kti_sourcesalesorderid, HelperDomain.GetFieldValue('kti_sourcesalesorderid', JT.AsObject()));
                Evaluate(LocationCode, HelperDomain.GetFieldValue('warehouse', JT.AsObject()));
                Evaluate(customername, HelperDomain.GetFieldValue('customername', JT.AsObject()));
                Evaluate(address, HelperDomain.GetFieldValue('address', JT.AsObject()));
                Evaluate(address2, HelperDomain.GetFieldValue('address2', JT.AsObject()));
                Evaluate(city, HelperDomain.GetFieldValue('city', JT.AsObject()));
                Evaluate(postcode, HelperDomain.GetFieldValue('postcode', JT.AsObject()));
                Evaluate(country, HelperDomain.GetFieldValue('country', JT.AsObject()));
                Evaluate(contactno, HelperDomain.GetFieldValue('contactno', JT.AsObject()));
                Evaluate(phoneno, HelperDomain.GetFieldValue('phoneno', JT.AsObject()));
                Evaluate(email, HelperDomain.GetFieldValue('email', JT.AsObject()));

                InsertSalesHeader(_salesHeader);
                _listOfOrderNos.Add(kti_sourcesalesorderid);
                _listOfOrderNos.Add(_salesHeader."No.");
                Clear(SI_JO);
                // SI_JO.Add('ExternalDocNo', No);
                SI_JO.Add('kti_sourcesalesorderid', kti_sourcesalesorderid);
                SI_JO.Add('OrderNo', _salesHeader."No.");
                SalesJArray.Add(SI_JO);
            end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure mapLine(jsonText: Text; _listOfOrderNos: List of [Text])
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
                if kti_sourcesalesorderid <> HelperDomain.GetFieldValue('kti_sourcesalesorderid', JT.AsObject()) then
                    Clear(LineNo);
                Evaluate(kti_sourcesalesorderid, HelperDomain.GetFieldValue('kti_sourcesalesorderid', JT.AsObject()));
                Clear(_salesHeader);
                _salesHeader.SetRange("Document Type", _salesHeader."Document Type"::Order);
                _salesHeader.SetRange("No.", _listOfOrderNos.Get(_listOfOrderNos.IndexOf(kti_sourcesalesorderid) + 1));
                if _salesHeader.FindFirst() then begin
                    Evaluate(ItemNo, HelperDomain.GetFieldValue('ItemNo', JT.AsObject()));
                    Evaluate(VariantCode, HelperDomain.GetFieldValue('VariantCode', JT.AsObject()));
                    Evaluate(Quantity, HelperDomain.GetFieldValue('Quantity', JT.AsObject()));
                    Evaluate(UnitofMeasureCode, HelperDomain.GetFieldValue('UnitofMeasureCode', JT.AsObject()));
                    Evaluate(kti_sourcesalesorderitemid, HelperDomain.GetFieldValue('kti_sourcesalesorderitemid', JT.AsObject()));
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
        _salesLine.Validate("Document Type", _salesLine."Document Type"::Order);
        _salesLine.Validate("Document No.", _salesHeader."No.");
        _salesLine.Validate("Line No.", LineNo);
        _salesLine.Validate(Type, _salesLine.Type::Item);
        _salesLine.Validate("No.", ItemNo);
        if VariantCode <> '0' then
            _salesLine.Validate("Variant Code", VariantCode);
        _salesLine.Validate("Location Code", LocationCode);
        _salesLine.Validate(Quantity, Quantity);
        _salesLine.Validate("Moo Source Sales Order Item ID", kti_sourcesalesorderitemid);
        _salesLine.Insert(true);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure InsertSalesHeader(var _salesHeader: Record "Sales Header")
    begin
        Clear(_salesHeader);
        _salesHeader.Init();
        _salesHeader.Validate("Document Type", _salesHeader."Document Type"::Order);
        _salesHeader.Validate("No. Series");
        _salesHeader.Validate("No.");
        _salesHeader.Validate("Sell-to Customer No.", CustNo);
        _salesHeader.Validate("Bill-to Customer No.", CustNo);
        _salesHeader.Validate("Posting Date", Today);
        _salesHeader.Validate("Document Date", Today);
        // _salesHeader.Validate("External Document No.", No);
        _salesHeader.Validate("Moo Source Sales Order ID", kti_sourcesalesorderid);
        _salesHeader.Validate("Location Code", LocationCode);
        if customername <> '0' then
            _salesHeader."Sell-to Customer Name" := customername;
        if address <> '0' then
            _salesHeader."Sell-to Address" := address;
        if address2 <> '0' then
            _salesHeader."Sell-to Address 2" := address2;
        if city <> '0' then
            _salesHeader."Sell-to City" := city;
        if postcode <> '0' then
            _salesHeader."Sell-to Post Code" := postcode;
        if country <> '0' then
            _salesHeader."Sell-to Country/Region Code" := country;
        if contactno <> '0' then
            _salesHeader."Sell-to Contact No." := contactno;
        if phoneno <> '0' then
            _salesHeader."Sell-to Phone No." := phoneno;
        if email <> '0' then
            _salesHeader."Sell-to E-Mail" := email;
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
