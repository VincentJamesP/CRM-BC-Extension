codeunit 70153 "Moo.SalesOrderDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    var
        SalesOrder: Codeunit "Moo.Model.SalesOrder";
        listOfOrderNos: List of [Text];
    begin
        SalesOrder.FromJsonHeader(object, listOfOrderNos);
        SalesOrder.FromJsonLine(object, listOfOrderNos);
        exit(SalesOrder.ToJson());
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
