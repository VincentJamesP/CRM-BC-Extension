codeunit 70150 "Moo.InvoiceDomain" implements "Moo.IDomain"
{
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    var
        salesInvoice: Codeunit "Moo.Model.SalesInvoice";
        listOfInvoiceNos: List of [Text];
    begin
        salesInvoice.FromJsonHeader(object, listOfInvoiceNos);
        salesInvoice.FromJsonLine(object, listOfInvoiceNos);
        // Commit();

        exit(salesInvoice.ToJson());
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(id: text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(id: Text): Text
    begin
    end;

}
