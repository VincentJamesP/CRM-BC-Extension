codeunit 70182 "Moo.PaymentSODomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    var
        paymentModel: Codeunit "Moo.Model.PaymentSO";
    begin
        paymentModel.FromJson(object);
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
