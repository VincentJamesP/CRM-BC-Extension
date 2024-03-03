codeunit 70412 "Moo.ProductDomain" implements "Moo.IDomain"
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
        ProductList: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := GetProductsByLocation(sourceData);
        responseData.WriteTo(ProductList);
        exit(ProductList);
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
    local procedure GetProductsByLocation(sourceData: JsonArray): JsonArray;
    var
        TokenCurrent: JsonToken;
        Products: JsonArray;
        ProductByLocation: JsonObject;
        ProductItems: JsonArray;
        ItemProperties: JsonObject;
        ItemTable: Record Item;
        ProductLocation: Text;
        ProductType: Enum "Item Type";
        HelperDomain: Codeunit "Moo.HelperDomain";
        VariantTable: Record "Item Variant";
        ProductModel: Codeunit "Moo.ProductModel";
    begin
        ItemTable.SetAutoCalcFields(Inventory);
        foreach TokenCurrent in sourceData do begin
            if TokenCurrent.IsObject() then begin
                // Assign Source Data to Local Parameters
                Evaluate(ProductLocation, HelperDomain.GetFieldValue('Store', TokenCurrent.AsObject()));

                // Filter Item Record using Source Data
                ItemTable.Reset();
                ItemTable.SetRange(Type, ProductType::Inventory);
                ItemTable.SetFilter("Location Filter", ProductLocation);
                ItemTable.SetFilter(Inventory, '>%1', 0);

                // If a data is retrieved loop through all the rows and insert 
                // it to the result variable
                if ItemTable.FindSet() then begin
                    repeat
                        // Filter Item Record using Source Data
                        VariantTable.Reset();
                        VariantTable.SetRange("Item No.", ItemTable."No.");

                        if VariantTable.FindSet() then begin
                            repeat
                                ItemProperties := ProductModel.PopulateItemProps(ItemTable, VariantTable.Code, ProductLocation);

                                // Add JSON Objects and Arrays to the output variable
                                ProductItems.Add(ItemProperties);
                                Clear(ItemProperties);
                            until VariantTable.Next() = 0;
                        end else begin
                            ItemProperties := ProductModel.PopulateItemProps(ItemTable, '', ProductLocation);

                            // Add JSON Objects and Arrays to the output variable
                            ProductItems.Add(ItemProperties);
                            Clear(ItemProperties);
                        end;
                    until ItemTable.Next() = 0;
                end;

                if ProductLocation = '' then begin
                    // if Product Location is not specified
                    // output the current items
                    exit(ProductItems);
                end;

            end;
        end;
        exit(ProductItems);
    end;

}
