codeunit 70176 "Moo.LocationDomain" implements "Moo.IDomain"
{

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(object: Text): Text
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
    procedure RetrieveByLocation(object: Text; var MooLocationTempTable: Record "Moo.LocationTempTable" temporary): Text
    var
        Company: Record Company;
        Location: Record Location;
        LocationModel: Codeunit "Moo.Model.Location";
        HelperDomain: Codeunit "Moo.HelperDomain";

        CompanyParam: Text[100];
        LocationParam: Text[100];
        JsnTokenAsArray: JsonToken;
        JsnTokenAsObject: JsonToken;
        Empty: Label '';
    //APIObject: Record ObjectAPI;
    begin
        if object <> '' then begin
            JsnTokenAsArray.ReadFrom(object);
            foreach JsnTokenAsObject in JsnTokenAsArray.AsArray() do begin
                CompanyParam := HelperDomain.GetFieldValue('Company', JsnTokenAsObject.AsObject());
                LocationParam := HelperDomain.GetFieldValue('Location', JsnTokenAsObject.AsObject());
            end;
        end;
        if CompanyParam <> '' then
            Company.SetFilter(Name, CompanyParam);

        if Company.FindSet() then
            repeat
                Clear(Location);
                Location.ChangeCompany(Company.Name);
                Location.SetCurrentKey("Code");
                if LocationParam <> '' then
                    Location.SetFilter("Code", LocationParam);
                if Location.FindSet() then
                    repeat
                        MooLocationTempTable.Company := Company.Name;
                        MooLocationTempTable."Location Code" := Location.Code;
                        MooLocationTempTable.Insert();
                    until Location.Next() = 0;
            until Company.Next() = 0;

        exit(LocationModel.ToJsonLocation(MooLocationTempTable));
    end;

}
