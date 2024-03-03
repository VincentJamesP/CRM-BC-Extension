codeunit 70162 "Moo.BinDomain" implements "Moo.IDomain"
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
    procedure RetrieveByBin(object: Text; var MooBinTempTable: Record "Moo.BinTempTable" temporary): Text
    var
        Company: Record Company;
        Bin: Record Bin;
        BinModel: Codeunit "Moo.Model.Bin";
        HelperDomain: Codeunit "Moo.HelperDomain";

        CompanyParam: Text[100];
        LocationParam: Text[100];
        ZoneParam: Text[100];
        BinParam: Text[100];
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
                ZoneParam := HelperDomain.GetFieldValue('Zone', JsnTokenAsObject.AsObject());
                BinParam := HelperDomain.GetFieldValue('Bin', JsnTokenAsObject.AsObject());
            end;
        end;
        if CompanyParam <> '' then
            Company.SetFilter(Name, CompanyParam);

        if Company.FindSet() then
            repeat
                Clear(Bin);
                Bin.ChangeCompany(Company.Name);
                Bin.SetCurrentKey("Location Code", "Zone Code", "Code");
                if LocationParam <> '' then
                    Bin.SetFilter("Location Code", LocationParam);

                if ZoneParam <> '' then
                    Bin.SetFilter("Zone Code", LocationParam);

                if BinParam <> '' then
                    Bin.SetFilter(Code, BinParam);


                if (LocationParam = '') and (ZoneParam = '') and (BinParam = '') then
                    Bin.SetFilter(Code, '<>%1', Empty);

                if Bin.FindSet() then
                    repeat
                        MooBinTempTable.Company := Company.Name;
                        MooBinTempTable."Location Code" := Bin."Location Code";
                        MooBinTempTable.Zone := Bin."Zone Code";
                        MooBinTempTable."Bin Code" := Bin.Code;
                        MooBinTempTable.Insert();
                    until Bin.Next() = 0;
            until Company.Next() = 0;

        exit(BinModel.ToJsonBin(MooBinTempTable));
    end;

}
