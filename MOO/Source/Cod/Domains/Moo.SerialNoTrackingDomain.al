codeunit 70403 "Moo.SerialNoTrackingDomain" implements "Moo.IDomain"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(sourceArr: Text): Text
    var
        HelperModel: Codeunit "Moo.HelperModel";
        sourceData: JsonArray;
        responseData: JsonArray;
        inventoryCheckResult: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := ValidateSerialNumber(sourceData);
        responseData.WriteTo(inventoryCheckResult);
        exit(inventoryCheckResult);
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
    local procedure ValidateSerialNumber(sourceData: JsonArray): JsonArray;
    var
        TokenCurrent: JsonToken;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        ItemTable: Record Item;
        ProductSKU: Text;
        ProductLocation: Text;
        ProductSerial: Text;
        ProductName: Text;
        IsAvailable: Boolean;
        TempSerialNoTable: Record TempSerialNoTable temporary;
        ProductSumQuantity: Decimal;
        IsExisting: Boolean;
        HelperDomain: Codeunit "Moo.HelperDomain";
        ProductType: Enum "Item Type";
    begin
        ItemTable.SetAutoCalcFields(Inventory);
        foreach TokenCurrent in sourceData do begin
            if TokenCurrent.IsObject() then begin
                // Assign Source Data to Local Parameters
                Evaluate(ProductSKU, HelperDomain.GetFieldValue('SKU', TokenCurrent.AsObject()));
                Evaluate(ProductLocation, HelperDomain.GetFieldValue('Store', TokenCurrent.AsObject()));
                Evaluate(ProductSerial, HelperDomain.GetFieldValue('SerialNumber', TokenCurrent.AsObject()));

                // Reset default values
                IsExisting := false;
                IsAvailable := false;
                Clear(ProductName);

                // Filter Item Record using Source Data
                ItemTable.Reset();
                ItemTable.SetRange("No.", ProductSKU);
                ItemTable.SetRange(Type, ProductType::Inventory);
                if ItemTable.FindFirst() then begin
                    ProductName := ItemTable.Description;
                end;
                ItemTable.SetFilter("Location Filter", ProductLocation);
                ItemTable.SetFilter("Serial No. Filter", ProductSerial);
                ItemTable.SetFilter(Inventory, '>%1', 0);

                // If a data is retrieved check if it was inserted to temporary table
                // then check the availability with the sum of inserted record's quantity
                // and current item's quantity
                if ItemTable.FindFirst() then begin
                    if Not TempSerialNoTable.IsEmpty() then begin
                        TempSerialNoTable.Reset();
                        TempSerialNoTable.SetRange(SKU, ProductSKU);
                        TempSerialNoTable.SetRange(Store, ProductLocation);
                        TempSerialNoTable.SetRange("Serial No.", ProductSerial);
                        if TempSerialNoTable.FindFirst() then begin
                            IsExisting := true;
                        end else begin
                            IsAvailable := true;
                        end;
                    end else begin
                        IsAvailable := true;
                    end;
                end else begin
                    if Not TempSerialNoTable.IsEmpty() then begin
                        TempSerialNoTable.Reset();
                        TempSerialNoTable.SetRange(SKU, ProductSKU);
                        TempSerialNoTable.SetRange(Store, ProductLocation);
                        TempSerialNoTable.SetRange("Serial No.", ProductSerial);
                        if TempSerialNoTable.FindFirst() then begin
                            IsExisting := true;
                        end;
                    end;
                end;

                // Add current item if not existing to temporary table
                if Not IsExisting then begin
                    TempSerialNoTable.Init();
                    TempSerialNoTable.Validate(SKU, ProductSKU);
                    TempSerialNoTable.Validate(Store, ProductLocation);
                    TempSerialNoTable.Validate("Serial No.", ProductSerial);
                    TempSerialNoTable.Insert(true);
                end;

                // Add output as object to array
                JsonObj.Add('SKU', ProductSKU);
                JsonObj.Add('ProductName', ProductName);
                JsonObj.Add('Store', ProductLocation);
                JsonObj.Add('SerialNumber', ProductSerial);
                JsonObj.Add('IsAvailable', IsAvailable);
                JsonArr.Add(JsonObj);
                Clear(JsonObj);
            end;
        end;
        exit(JsonArr);
    end;
}
