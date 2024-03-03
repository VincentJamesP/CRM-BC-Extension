codeunit 70181 "Moo.Model.PaymentSO" implements "Moo.IModel"
{

    procedure ToJson(): Text
    begin
    end;

    procedure FromJson(inputJson: Text)
    begin
        map(inputJson);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure map(JsonText: Text)
    var
        Token: JsonToken;
        JT: JsonToken;
        JO: JsonObject;
        Token2: JsonToken;
        Token3: JsonToken;
        JV: JsonValue;
        LineNo: Integer;
        SalesHeader: Record "Sales Header";
        Amt: Decimal;
        ExternalDocNo: Text;
        tenderCode: Text;
        NoSeries: Codeunit NoSeriesManagement;
        DocNo: Code[20];
        CustPayment: Record "Moo.CustomerPayments";
        GenJnlLine: Record "Gen. Journal Line";
        HelperDomain: Codeunit "Moo.HelperDomain";
        JTTender: JsonToken;
        JOTender: JsonObject;
        JT2: JsonToken;
    begin
        DocNo := NoSeries.GetNextNo('GJNL-RCPT', Today, true);
        Token.ReadFrom(jsonText);
        if Token.IsValue() then begin
            JV := Token.AsValue();
            Token2.ReadFrom(JV.AsText());
            JO := Token2.AsObject();
        end else
            JO := Token.AsObject();
        GenJnlLine.SetRange("Journal Template Name", 'CASHRCPT');
        GenJnlLine.SetRange("Journal Batch Name", 'PAYMENT-SO');
        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No.";
        JO.Get('payment_method', Token3);
        foreach JT in Token3.AsArray() do begin
            if JT.IsObject() then begin
                JOTender := JT.AsObject();
                JOTender.Get('tender_type', JTTender);
                SalesHeader.Reset();
                SalesHeader.SetRange("External Document No.", HelperDomain.GetFieldValue('No', JT.AsObject()));
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                if SalesHeader.FindFirst() then begin
                    foreach JT2 in JTTender.AsArray() do begin
                        Clear(ExternalDocNo);
                        Clear(Amt);
                        Clear(tenderCode);
                        Evaluate(ExternalDocNo, HelperDomain.GetFieldValue('TRN', JT2.AsObject()));
                        Evaluate(Amt, HelperDomain.GetFieldValue('amount', JT2.AsObject()));
                        Evaluate(tenderCode, HelperDomain.GetFieldValue('code', JT2.AsObject()));
                        if Amt > 0 then begin
                            CustPayment.Reset();
                            CustPayment.SetRange("Payment Code", tenderCode);
                            if CustPayment.FindFirst() then begin
                                LineNo += 10000;
                                insertCashReceiptJnl(LineNo, SalesHeader, Amt, DocNo, ExternalDocNo, CustPayment."Bal. G/L Acct. No.");
                            end;
                        end;
                    end;
                end;
            end;
        end;

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure insertCashReceiptJnl(LineNo: Integer; _salesInvHdr: Record "Sales Header"; _amount: Decimal; _docNo: Code[20]; externalDocNo: Text; _balAcctNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Init();
        GenJnlLine.Validate("Journal Template Name", 'CASHRCPT');
        GenJnlLine.Validate("Journal Batch Name", 'PAYMENT-SO');
        GenJnlLine.Validate("Line No.", LineNo);
        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
        GenJnlLine.Validate("Posting Date", Today);
        GenJnlLine.Validate("Document No.", _docNo);
        GenJnlLine.Validate(Comment, externalDocNo);
        GenJnlLine."External Document No." := _salesInvHdr."External Document No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", _salesInvHdr."Sell-to Customer No.");
        GenJnlLine.Validate(Amount, -Abs(_amount));
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine."Bal. Account No." := _balAcctNo;
        GenJnlLine.Insert();
    end;
}

