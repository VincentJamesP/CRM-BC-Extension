codeunit 70186 "Moo.PriceController" implements "Moo.IController"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(functionID: Integer; object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(functionID: Integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.PriceFunctionEnum";
    begin
        functionsEnum := Enum::"Moo.PriceFunctionEnum".FromInteger(functionID);
        case functionsEnum of
            functionsEnum::GetCampaignDetails:
                begin
                    exit(GetCampaignDetails(object));
                end;
        end;
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
    local procedure GetCampaignDetails(jsonData: Text): Text
    var
        PriceDomain: Codeunit "Moo.PriceDomain";
        CampaignDetails: Text;
    begin
        CampaignDetails := PriceDomain.Retrieve(jsonData);
        exit(CampaignDetails);
    end;
}
