page 70500 "API Testing"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group("Choose a method")
            {
                field("API Method"; method)
                {
                    Editable = true;
                    ApplicationArea = All;
                    Caption = 'API Method';
                }
            }
            group("API Request Body - Postman")
            {
                field(APICall; APICallBody)
                {
                    MultiLine = true;
                    ApplicationArea = All;
                }
            }
            group("API Response")
            {
                field(Response; response)
                {
                    MultiLine = true;
                    ApplicationArea = All;
                }
            }
            group("For External API Call")
            {
                field(APIChannel; APIChannel)
                {
                    ApplicationArea = All;
                }
                field(APIFunction; APIFunction)
                {
                    ApplicationArea = All;
                }
                field(APIMethod; APIMethod)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        // Adds the action called "My Actions" to the Action menu 
        area(Processing)
        {
            action("Call MooAPI")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    mooAPI: Codeunit "Moo.API";
                    HelperDomain: Codeunit "Moo.HelperDomain";
                    source: Text;
                    TransType: Integer;
                    FunctionType: Integer;
                    jsonO: JsonObject;
                    JsonData: Text;
                begin
                    jsonO.ReadFrom(APICallBody);
                    Evaluate(source, HelperDomain.GetFieldValue('source', jsonO));
                    Evaluate(TransType, HelperDomain.GetFieldValue('transType', jsonO));
                    Evaluate(FunctionType, HelperDomain.GetFieldValue('functionType', jsonO));
                    Evaluate(JsonData, HelperDomain.GetFieldValue('jsonData', jsonO));
                    case method of
                        method::Create:
                            response := mooAPI.Create(source, TransType, FunctionType, JsonData);
                        method::Retrieve:
                            response := mooAPI.Retrieve(source, TransType, FunctionType, JsonData);
                        method::Update:
                            response := mooAPI.Update(source, TransType, FunctionType, JsonData);
                    // method::Delete:
                    //     response := mooAPI.Delete(source, TransType, FunctionType, JsonData);
                    end;
                end;

            }
            action("Item Rec to Json")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Helper: Codeunit "Moo.HelperDomain";
                    ItemRec: Record Item;
                    JO: JsonObject;
                begin
                    if APICallBody <> '' then
                        ItemRec.Get(APICallBody)
                    else
                        ItemRec.FindFirst();
                    JO := Helper.Rec2Json(ItemRec);
                    JO.WriteTo(response);
                end;

            }
            action("Test External API")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                var
                    APIHelper: Codeunit "Moo.API Management Domain";
                begin
                    response := APIHelper.CallWebservice(APIChannel, APIFunction, APICallBody, APIMethod);
                end;
            }
        }
    }

    var
        response: Text;
        APICallBody: Text;
        method: Option Create,Retrieve,Update,Delete;
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";

}