codeunit 70417 "Moo.SalesReportDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(sourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        sourceData: JsonArray;
        responseData: JsonArray;
        ReportsGenerated: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := GetReportsByCustomer(sourceData);
        responseData.WriteTo(ReportsGenerated);
        exit(ReportsGenerated);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(sourceArr: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetReportsByCustomer(sourceData: JsonArray): JsonArray;
    var
        TempBlob_lRec: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        RecRef: RecordRef;
        FileMgt: Codeunit "File Management";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        TempBlob_lRec.CreateOutStream(BlobOutStream, TEXTENCODING::UTF8);
        SalesInvoiceHeader.Reset;
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", '20000');
        RecRef.GetTable(SalesInvoiceHeader);
        REPORT.SAVEAS(124, '', REPORTFORMAT::Pdf, BlobOutStream, RecRef);
        FileMgt.BLOBExport(TempBlob_lRec, 'Sales Report.pdf', TRUE);
        exit(sourceData);
    end;
}
