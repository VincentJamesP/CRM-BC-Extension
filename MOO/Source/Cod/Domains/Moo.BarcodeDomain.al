codeunit 70413 "Moo.BarcodeDomain" implements "Moo.IDomain"
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
        BarcodeList: Text;
    begin
        sourceData := HelperModel.MapToJsonArray(sourceArr);
        responseData := GetBarcode(sourceData);
        responseData.WriteTo(BarcodeList);
        exit(BarcodeList);
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
    local procedure GetBarcode(sourceData: JsonArray): JsonArray;
    var
        TokenCurrent: JsonToken;
        Products: JsonArray;
        HelperDomain: Codeunit "Moo.HelperDomain";
        ReferenceType: Enum "Item Reference Type";
        ItemRefTable: Record "Item Reference";
        ItemBarCodes: JsonArray;
        ItemBarCode: JsonObject;
        ProductSKU: Text;
    begin
        foreach TokenCurrent in sourceData do begin
            if TokenCurrent.IsObject() then begin
                // Assign Source Data to Local Parameters
                Evaluate(ProductSKU, HelperDomain.GetFieldValue('SKU', TokenCurrent.AsObject()));

                // Retrieve Barcodes for the current item
                ItemRefTable.Reset();
                ItemRefTable.SetRange("Reference Type", ReferenceType::"Bar Code");
                ItemRefTable.SetFilter("Item No.", ProductSKU);
                if ItemRefTable.FindSet() then begin
                    repeat
                        ItemBarCode.Add('SKU', ItemRefTable."Item No.");
                        ItemBarCode.Add('VariantCode', ItemRefTable."Variant Code");
                        ItemBarCode.Add('BarCode', ItemRefTable."Reference No.");
                        ItemBarCodes.Add(ItemBarCode);
                        Clear(ItemBarCode);
                    until ItemRefTable.Next() = 0;
                end;

                if ProductSKU <> '' then begin
                    // Add output as object to array
                    Products.Add(ItemBarCodes);
                end else begin
                    // if Product Location is not specified
                    // output the current items
                    exit(ItemBarCodes);
                end;

                Clear(ItemBarCodes);
            end;
        end;
        exit(Products);
    end;

}
