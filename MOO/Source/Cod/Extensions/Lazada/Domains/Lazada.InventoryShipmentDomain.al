codeunit 70453 "Lazada.InventoryShipment" implements "Moo.IDomain"
{
    var
        ErrText: TextConst ENU = 'Bad Request';

    procedure Create(SourceArr: Text): Text
    begin
    end;

    procedure Retrieve(object: Text): Text
    begin
    end;

    procedure Update(object: Text): Text
    begin
    end;

    procedure Delete(object: Text): Text
    begin
    end;

    procedure GenerateURL(): Text;
    var

        Client: HttpClient;
        Response: HttpResponseMessage;
        json: Text;
        jsonObj: JsonObject;
        FunctionEndpoint: Text;
        Fact: Text;
        TrimmedFact: Text;
        Helper: Codeunit "Moo.HelperDomain";
        IPAddr: Text;
        TemporaryResponse: Text;
    begin
        FunctionEndpoint := 'https://api.ipify.org?format=json';
        client.Get(FunctionEndpoint, Response);

        //Reads the response content from the Azure Function
        Response.Content().ReadAs(json);

        if not jsonObj.ReadFrom(json) then
            Error(ErrText);

        //Here you need to parse jsonObj (the JSON of your response)
        Evaluate(IPAddr, Helper.GetFieldValue('ip', jsonObj));
        Message('URL generated successfully!');
        TemporaryResponse := 'https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-611.exe';
        exit(TemporaryResponse);

    end;
}