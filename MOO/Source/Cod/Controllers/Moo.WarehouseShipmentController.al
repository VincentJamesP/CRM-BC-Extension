codeunit 70179 "Moo.WhseShipmentController" implements "Moo.IController"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(mooFunction: integer; object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(functionID: Integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.WarehouseShipmentEnum";
    begin
        functionsEnum := Enum::"Moo.WarehouseShipmentEnum".FromInteger(functionID);
        case functionsEnum of
            functionsEnum::GetWarehouseShipmentDocument:
                begin
                    exit(GetWarehouseShipmentDocument(object));
                end;
            functionsEnum::GetBySalesDocNoLineNoItemNo:
                begin
                    exit(GetBySalesDocNoLineNoItemNo(object));
                end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(functionID: Integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.WarehouseShipmentEnum";
    begin
        functionsEnum := Enum::"Moo.WarehouseShipmentEnum".FromInteger(functionID);
        case functionsEnum of
            functionsEnum::UpdateShipmentProviderTrackingNumber:
                begin
                    exit(UpdateShipmentProviderTrackingNumber(object));
                end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(functionID: Integer; object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetWarehouseShipmentDocument(jsonData: Text): Text
    var
        WarehouseShipmentDomain: Codeunit "Moo.WhseShipmentDomain";
    begin
        exit(WarehouseShipmentDomain.Retrieve(jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure UpdateShipmentProviderTrackingNumber(jsonData: Text): Text
    var
        WarehouseShipmentDomain: Codeunit "Moo.WhseShipmentDomain";
    begin
        exit(WarehouseShipmentDomain.UpdateShipmentProviderTrackingNumber(jsonData));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetBySalesDocNoLineNoItemNo(jsonData: Text): Text
    var
        WarehouseShipmentDomain: Codeunit "Moo.WhseShipmentDomain";
    begin
        exit(WarehouseShipmentDomain.GetBySalesDocNoLineNoItemNo(jsonData));
    end;

}
