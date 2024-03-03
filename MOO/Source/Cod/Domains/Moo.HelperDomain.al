codeunit 70161 "Moo.HelperDomain"
{
    var
        ErrText1: TextConst ENU = 'Parameter Rec is not a record.';
        ErrText2: TextConst ENU = '%1 is not a supported field type.';

    // Returns Json object's field value
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure GetFieldValue(FieldName: Text[50]; JSObject: JsonObject): Text
    var
        JToken: JsonToken;
        JSValue: JsonValue;
    begin
        if not JSObject.Get(FieldName, JToken) then
            exit('0');
        if JToken.IsValue() then
            JSValue := JToken.AsValue();
        if JSValue.IsNull then
            exit('0');
        exit(JSValue.AsText());
    end;

    // Returns Json array's field value/s
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure GetArrayValues(FieldName: Text[50]; JSObject: JsonObject): JsonArray;
    var
        JToken: JsonToken;
        JSValue: JsonValue;
        LoopToken: JsonToken;
        JSArray: JsonArray;
        ListData: List of [Text];
    begin
        if not JSObject.Get(FieldName, JToken) then begin
            JSArray.Add('{0}');
            exit(JSArray);
        end;

        if JToken.IsArray() then begin
            JSArray := JToken.AsArray();
            exit(JSArray);
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Json2Rec(JO: JsonObject; Rec: Variant): Variant
    var
        Ref: RecordRef;
    begin
        Ref.GetTable(Rec);
        exit(Json2Rec(JO, Ref.Number()));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Json2Rec(JO: JsonObject; TableNo: Integer): Variant
    var
        Ref: RecordRef;
        FR: FieldRef;
        FieldHash: Dictionary of [Text, Integer];
        i: Integer;
        JsonKey: Text;
        T: JsonToken;
        JsonKeyValue: JsonValue;
        RecVar: Variant;
    begin
        Ref.OPEN(TableNo);
        for i := 1 to Ref.FieldCount() do begin
            FR := Ref.FieldIndex(i);
            FieldHash.Add(GetJsonFieldName(FR), FR.Number);
        end;
        Ref.Init();
        foreach JsonKey in JO.Keys() do begin
            if JO.Get(JsonKey, T) then begin
                if T.IsValue() then begin
                    JsonKeyValue := T.AsValue();
                    FR := Ref.Field(FieldHash.Get(JsonKey));
                    AssignValueToFieldRef(FR, JsonKeyValue);
                end;
            end;
        end;
        RecVar := Ref;
        exit(RecVar);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Rec2Json(Rec: Variant): JsonObject
    var
        Ref: RecordRef;
        Out: JsonObject;
        FRef: FieldRef;
        i: Integer;
    begin
        if not Rec.IsRecord then
            error(ErrText1);
        Ref.GetTable(Rec);
        for i := 1 to Ref.FieldCount() do begin
            FRef := Ref.FieldIndex(i);
            case FRef.Class of
                FRef.Class::Normal:
                    Out.Add(GetJsonFieldName(FRef), FieldRef2JsonValue(FRef));
                FRef.Class::FlowField:
                    begin
                        FRef.CalcField();
                        Out.Add(GetJsonFieldName(FRef), FieldRef2JsonValue(FRef));
                    end;
            end;
        end;
        exit(Out);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure FieldRef2JsonValue(FRef: FieldRef): JsonValue
    var
        V: JsonValue;
        D: Date;
        DT: DateTime;
        T: Time;
    begin
        case FRef.Type() of
            FieldType::Date:
                begin
                    D := FRef.Value;
                    V.SetValue(D);
                end;
            FieldType::Time:
                begin
                    T := FRef.Value;
                    V.SetValue(T);
                end;
            FieldType::DateTime:
                begin
                    DT := FRef.Value;
                    V.SetValue(DT);
                end;
            else
                V.SetValue(Format(FRef.Value, 0, 9));
        end;
        exit(v);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetJsonFieldName(FRef: FieldRef): Text
    var
        Name: Text;
        i: Integer;
    begin
        Name := FRef.Name();
        for i := 1 to Strlen(Name) do begin
            if Name[i] < '0' then
                Name[i] := '_';
        end;
        exit(Name.Replace('__', '_').TrimEnd('_').TrimStart('_'));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure AssignValueToFieldRef(var FR: FieldRef; JsonKeyValue: JsonValue)
    begin
        case FR.Type() of
            FieldType::Code,
            FieldType::Text:
                FR.Value := JsonKeyValue.AsText();
            FieldType::Integer:
                FR.Value := JsonKeyValue.AsInteger();
            FieldType::Date:
                FR.Value := JsonKeyValue.AsDate();
            else
                error(ErrText2, FR.Type());
        end;
    end;
}
