codeunit 70156 "Moo.InvoiceController" implements "Moo.IController"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(functions: integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.InvoiceFunctionEnum";
    begin
        functionsEnum := Enum::"Moo.InvoiceFunctionEnum".FromInteger(functions);
        case functionsEnum of
            functionsEnum::PostInvoicePaymentLineItemTracking:
                begin
                    exit(PostInvoicePaymentLinesItemTracking(object));
                end;
            functionsEnum::CreateInvoice:
                begin
                    exit(CreateInvoice(object));
                end;
            functionsEnum::CreateSalesReport:
                begin
                    exit(CreateSalesReport(object));
                end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(functionID: Integer; object: Text): Text
    begin


    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(functionID: Integer; object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(functionID: Integer; object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure PostInvoicePaymentLinesItemTracking(jsonData: Text): Text
    var
        invDomain: Codeunit "Moo.InvoiceDomain";
        itemTrackingDomain: Codeunit "Moo.ItemTrackingDomain";
        HelperModel: Codeunit "Moo.HelperModel";
        paymentDomain: Codeunit "Moo.PaymentDomain";
        LoopObject: Text;
        LoopToken: JsonToken;
        sourceData: JsonArray;
        invoicesJson: Text;
        logText: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(jsonData);
        foreach LoopToken in sourceData do begin
            LoopToken.AsObject().WriteTo(LoopObject);
            invoicesJson := invDomain.Create(LoopObject);
            logText := itemTrackingDomain.Create(LoopObject);
            PostInvoices(invoicesJson);
            logText := paymentDomain.Create(LoopObject);
            PostPaymentLines();
        end;
        Commit();

        exit(invoicesJson);
        // exit('Payment lines inserted');
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateInvoice(jsonData: Text): Text
    var
        domain: Codeunit "Moo.InvoiceDomain";
    begin
        exit(domain.Create(jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure PostInvoices(jsonData: Text)
    var
        JO: JsonObject;
        JT: JsonToken;
        JT2: JsonToken;
        Token: JsonToken;
        salesPost: Codeunit "Sales-Post";
        salesheader: Record "Sales Header";
    begin
        Token.ReadFrom(jsonData);
        salesPost.SetSuppressCommit(true);
        foreach JT in Token.AsArray() do begin
            JT.AsObject().Get('InvoiceNo', JT2);
            salesheader.SetRange("Document Type", salesheader."Document Type"::Invoice);
            salesheader.SetRange("No.", JT2.AsValue().AsText());
            if salesheader.FindFirst() then begin
                salesPost.Run(salesheader);
            end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure PostPaymentLines()
    var
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlPostBatch.SetSuppressCommit(true);
        GenJnlLine.SetRange("Journal Template Name", 'CASHRCPT');
        GenJnlLine.SetRange("Journal Batch Name", 'PAYMENT');
        if GenJnlLine.FindSet() then
            GenJnlPostBatch.Run(GenJnlLine);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure CreateSalesReport(jsonData: Text): Text
    var
        domain: Codeunit "Moo.SalesReportDomain";
    begin
        exit(domain.Create(jsonData));
    end;
}
