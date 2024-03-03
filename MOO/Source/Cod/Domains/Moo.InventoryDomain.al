codeunit 70402 "Moo.InventoryDomain" implements "Moo.IDomain"
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
        responseData := CheckProductsAvailability(sourceData);
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
    local procedure CheckProductsAvailability(sourceData: JsonArray): JsonArray;
    var
        TokenCurrent: JsonToken;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        ItemTable: Record Item;
        ProductSKU: Text;
        ProductLocation: Text;
        ProductName: Text;
        ProductQuantity: Decimal;
        IsAvailable: Boolean;
        TempItemTable: Record TempItemTable temporary;
        ProductSumQuantity: Decimal;
        IsExisting: Boolean;
        ProductType: Enum "Item Type";
        HelperDomain: Codeunit "Moo.HelperDomain";
    begin
        ItemTable.SetAutoCalcFields(Inventory);
        foreach TokenCurrent in sourceData do begin
            if TokenCurrent.IsObject() then begin
                // Assign Source Data to Local Parameters
                Evaluate(ProductSKU, HelperDomain.GetFieldValue('SKU', TokenCurrent.AsObject()));
                Evaluate(ProductLocation, HelperDomain.GetFieldValue('Store', TokenCurrent.AsObject()));
                Evaluate(ProductQuantity, HelperDomain.GetFieldValue('Quantity', TokenCurrent.AsObject()));

                // Reset default values
                IsExisting := false;
                IsAvailable := false;
                ProductSumQuantity := 0;
                Clear(ProductName);

                // Filter Item Record using Source Data
                ItemTable.Reset();
                ItemTable.SetRange("No.", ProductSKU);
                ItemTable.SetRange(Type, ProductType::Inventory);
                if ItemTable.FindFirst() then begin
                    ProductName := ItemTable.Description;
                end;
                ItemTable.SetFilter("Location Filter", ProductLocation);
                ItemTable.SetFilter(Inventory, '>=%1', ProductQuantity);

                // If a data is retrieved check if it was inserted to temporary table
                // then check the availability with the sum of inserted record's quantity
                // and current item's quantity
                if ItemTable.FindFirst() then begin
                    if Not TempItemTable.IsEmpty() then begin
                        TempItemTable.Reset();
                        TempItemTable.SetRange(SKU, ProductSKU);
                        TempItemTable.SetRange(Store, ProductLocation);
                        if TempItemTable.FindFirst() then begin
                            IsExisting := true;
                            ProductSumQuantity := TempItemTable.Quantity + ProductQuantity;
                            if ItemTable.Inventory >= ProductSumQuantity then begin
                                TempItemTable.Validate(Quantity, ProductSumQuantity);
                                TempItemTable.Modify();
                                IsAvailable := true;
                            end;
                        end else begin
                            IsAvailable := true;
                        end;
                    end else begin
                        IsAvailable := true;
                    end;
                end else begin
                    if Not TempItemTable.IsEmpty() then begin
                        TempItemTable.Reset();
                        TempItemTable.SetRange(SKU, ProductSKU);
                        TempItemTable.SetRange(Store, ProductLocation);
                        if TempItemTable.FindFirst() then begin
                            IsExisting := true;
                        end;
                    end;
                end;

                // Add current item if not existing to temporary table
                if Not IsExisting then begin
                    TempItemTable.Init();
                    TempItemTable.Validate(SKU, ProductSKU);
                    TempItemTable.Validate(Store, ProductLocation);
                    TempItemTable.Validate(Quantity, ProductQuantity);
                    TempItemTable.Insert(true);
                end;

                // Add output as object to array
                JsonObj.Add('SKU', ProductSKU);
                JsonObj.Add('ProductName', ProductName);
                JsonObj.Add('IsAvailable', IsAvailable);
                JsonArr.Add(JsonObj);
                Clear(JsonObj);
            end;
        end;
        exit(JsonArr);
    end;

}
