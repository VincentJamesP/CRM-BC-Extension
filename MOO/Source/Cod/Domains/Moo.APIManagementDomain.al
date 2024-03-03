codeunit 70180 "Moo.API Management Domain" implements "Moo.IDomain"
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

    procedure GetAuthenticationToken(Channel: Enum "Moo.API Channel"): Text
    var
        ResponseText: Text;
        TokenResponseText: Text;
        JObjectResult: JsonObject;
        WebClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        APIHeader: Record "Moo. API Header";
    begin
        APIHeader := GetAPIHeader(Channel);
        WebClient.DefaultRequestHeaders.Add('OC-Api-App-Key', APIHeader."Client ID");
        WebClient.DefaultRequestHeaders.Add('Ocp-Apim-Subscription-Key', APIHeader."Client Secret");
        WebClient.Get(APIHeader."Authorization URL", ResponseMessage);

        if ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ResponseText);

            if not JObjectResult.ReadFrom(ResponseText) then
                Error('Error Read JSON');

            TokenResponseText := GetJsonToken(JObjectResult, 'token').AsValue().AsText();
            // TokenExpiry := GetJsonToken(JObjectResult, 'expiry_date').AsValue().AsDateTime();

        end else
            Error('Webservice Error');


        exit(TokenResponseText);
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error(StrSubstNo('Token %1 not found', TokenKey));
    end;

    // procedure GetAuthenticationToken(ApiSetup: Record "Moo.API Line"; ForceRenewal: Boolean): Text
    // var
    //     TokenResponseText: Text;
    //     TokenExpiry: DateTime;
    //     TokenOutStream: OutStream;
    //     TokenInStream: InStream;
    //     AuthPayload: Text;
    // begin
    // if (ApiSetup."Token valid until" <= CurrentDateTime()) or ForceRenewal then begin
    //     //Get fresh Token 
    //     TokenResponseText := GetFreshAuthenticationToken(ApiSetup, TokenExpiry);

    //     //Write Token to Blob
    //     ApiSetup."API Token".CreateOutStream(TokenOutStream);
    //     TokenOutStream.WriteText(TokenResponseText);

    //     //Calculate the expriation date of the token. 
    //     //Should be defined by the API or even delivered in the response
    //     if TokenExpiry <> 0DT then
    //         ApiSetup."Token valid until" := TokenExpiry;
    //     ApiSetup.Modify();
    // end else begin
    //     ApiSetup.CalcFields("API Token");

    //     //Read Token from Blob
    //     ApiSetup."API Token".CreateInStream(TokenInStream);
    //     TokenInStream.ReadText(TokenResponseText);
    // end;

    // //Return the token
    // exit(TokenResponseText);
    //end;

    procedure CallWebservice(Channel: Enum "Moo.API Channel"; APIFunction: Enum "Moo.APIFunctionsEnum"; PayLoadText: Text; APIMethod: Enum "Moo.API Method Enum"): Text
    var
        ResponseText: Text;
        TokenResponseText: Text;
        JObjectResult: JsonObject;
        WebClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        PayLoad: HttpContent;

        APIHeader: Record "Moo. API Header";
        APILine: Record "Moo.API Line";
        Token: Text;
        Headers: HttpHeaders;
    begin
        PayLoad.WriteFrom(PayLoadText);
        APIHeader := GetAPIHeader(Channel);
        APILine := GetAPILine(Channel, APIFunction);
        Token := GetAuthenticationToken(Channel);
        WebClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', Token));
        WebClient.DefaultRequestHeaders.Add('OC-Api-App-Key', APIHeader."Client ID");
        WebClient.DefaultRequestHeaders.Add('Ocp-Apim-Subscription-Key', APIHeader."Client Secret");
        WebClient.DefaultRequestHeaders.Add('Company-Id', Format(APIHeader."Company ID"));
        WebClient.DefaultRequestHeaders.Add('Instance-Type', Format(APIHeader."Instance Type"));

        PayLoad.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        case APIMethod of
            APIMethod::GET:
                WebClient.Get(APIHeader."Base URL" + APILine.Path, ResponseMessage);
            APIMethod::PATCH:
                begin
                    WebClient.Put(APIHeader."Base URL" + APILine.Path, PayLoad, ResponseMessage)
                end;
            APIMethod::POST:
                begin
                    WebClient.Post(APIHeader."Base URL" + APILine.Path, PayLoad, ResponseMessage);
                end;

        end;
        if ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ResponseText);
        end else
            ResponseText := ResponseMessage.ReasonPhrase;
        // Error('Webservice Error');

        exit(ResponseText);
    end;

    procedure GetAPIHeader(Channel: Enum "Moo.API Channel"): Record "Moo. API Header"
    var
        APIHeader: Record "Moo. API Header";
    begin
        APIHeader.SetRange(Channel, Channel);
        if APIHeader.FindSet() then
            exit(APIHeader);
        Error('Channel does not exist.');
    end;

    procedure GetAPILine(Channel: Enum "Moo.API Channel"; APIFunction: Enum "Moo.APIFunctionsEnum"): Record "Moo.API Line"
    var
        APILine: Record "Moo.API Line";
    begin
        APILine.SetRange(Channel, Channel);
        APILine.SetRange("API Function", APIFunction);
        if APILine.FindSet() then
            exit(APILine);
        Error('Channel does not exist.');
    end;
}
