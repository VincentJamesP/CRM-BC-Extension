codeunit 70505 "Lazada.ProductStockModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure GetProductStocks(companyid: Text; ItemNo: Code[20]; VariantCode: Code[20]; LocationCode: Code[20]): JsonObject
    var
        ItemRec: Record Item;
        HelperDomain: Codeunit "Moo.HelperDomain";
        JO: JsonObject;
        ProductStocksTemp: Record "Lazada.ProductStockTempTable" temporary;
        SerialNumbersJA: JsonArray;
        LocationRec: Record Location;
    begin
        ItemRec.Reset();
        ItemRec.SetAutoCalcFields(Inventory);
        ItemRec.SetRange("No.", ItemNo);
        ItemRec.SetFilter("Variant Filter", VariantCode);
        ItemRec.SetFilter("Location Filter", LocationCode);
        if ItemRec.FindFirst() then begin
            ProductStocksTemp.Init();
            Evaluate(ProductStocksTemp.companyid, companyid);
            ProductStocksTemp.product := ItemRec."No.";
            ProductStocksTemp.qtyonhand := ItemRec.Inventory;
            ProductStocksTemp.unit := ItemRec."Base Unit of Measure";
            ProductStocksTemp.warehouse := LocationCode;
            LocationRec.Get(LocationCode);
            ProductStocksTemp.kti_storecode := LocationRec."Moo Channel Code";
        end;
        Clear(JO);
        JO := HelperDomain.Rec2Json(ProductStocksTemp);
        // JO.Add('serialnumbers', SerialNumbersJA);
        exit(JO);
    end;
}
