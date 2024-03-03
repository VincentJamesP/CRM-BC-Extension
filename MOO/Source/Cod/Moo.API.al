codeunit 70152 "Moo.API"
{
    var
        ErrText: TextConst ENU = 'JSON Data cannot be null or empty.';

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(source: Text; transType: Integer; functionType: Integer; jsonData: Text): Text;
    var
        msg: Text;
        mooController: Interface "Moo.IController";
        transTypeEnum: Enum "Moo.TransType";
    begin
        if jsonData = '' then begin
            Error(ErrText);
        end;
        transTypeEnum := Enum::"Moo.TransType".FromInteger(transType);
        Evaluate(transTypeEnum, format(transType));
        mooController := transTypeEnum;
        exit(mooController.Create(functionType, jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(source: Text; transType: Integer; functionType: Integer; jsonData: Text): Text;
    var
        msg: Text;
        mooController: Interface "Moo.IController";
        transTypeEnum: Enum "Moo.TransType";
    begin
        if jsonData = '' then begin
            Error(ErrText);
        end;
        transTypeEnum := Enum::"Moo.TransType".FromInteger(transType);
        Evaluate(transTypeEnum, format(transType));
        mooController := transTypeEnum;
        exit(mooController.Retrieve(functionType, jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(source: Text; transType: Integer; functionType: Integer; jsonData: Text): Text
    var
        msg: Text;
        mooController: Interface "Moo.IController";
        transTypeEnum: Enum "Moo.TransType";
    begin
        if jsonData = '' then begin
            Error(ErrText);
        end;
        transTypeEnum := Enum::"Moo.TransType".FromInteger(transType);
        Evaluate(transTypeEnum, format(transType));
        mooController := transTypeEnum;
        exit(mooController.Update(functionType, jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(modelType: Integer; id: Text): Text;
    begin

    end;
}
