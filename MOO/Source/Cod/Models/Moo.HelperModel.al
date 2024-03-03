codeunit 70407 "Moo.HelperModel"
{
    // Convert Json Text Data to JsonArray Data Type
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure MapToJsonArray(jsonData: Text): JsonArray;
    var
        TokenInput: JsonToken;
        TokenArray: JsonToken;
        JsonArr: JsonArray;
        JsonVal: JsonValue;
    begin
        TokenInput.ReadFrom(jsonData);
        if TokenInput.IsValue() then begin
            // From API Call
            JsonVal := TokenInput.AsValue();
            TokenArray.ReadFrom(JsonVal.AsText());
            JsonArr := TokenArray.AsArray();
        end else begin
            // From Page Call
            JsonArr := TokenInput.AsArray();
        end;

        exit(JsonArr);
    end;

    // Convert Json Text Data to JsonObject Data Type
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure MapToJsonObject(jsonData: Text): JsonObject;
    var
        TokenInput: JsonToken;
        TokenObj: JsonToken;
        JsonObj: JsonObject;
        JsonVal: JsonValue;
    begin
        TokenInput.ReadFrom(jsonData);
        if TokenInput.IsValue() then begin
            // From API Call
            JsonVal := TokenInput.AsValue();
            TokenObj.ReadFrom(JsonVal.AsText());
            JsonObj := TokenObj.AsObject();
        end else begin
            // From Page Call
            JsonObj := TokenInput.AsObject();
        end;

        exit(JsonObj);
    end;
}