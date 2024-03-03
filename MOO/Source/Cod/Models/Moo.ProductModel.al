codeunit 70416 "Moo.ProductModel" implements "Moo.IModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ToJson(): Text
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure FromJson(inputJson: Text)
    begin
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure PopulateItemProps(ItemRow: Record Item; VariantCode: Code[10]; ProductLocation: Text): JsonObject;
    var
        ItemProperties: JsonObject;
        UnitPrice: Decimal;
    begin
        UnitPrice := GetUnitPrice(ItemRow."No.", VariantCode);
        ItemProperties.Add('SKU', ItemRow."No.");
        ItemProperties.Add('ProductName', ItemRow.Description);
        ItemProperties.Add('VariantCode', VariantCode);
        ItemProperties.Add('Location', ProductLocation);
        ItemProperties.Add('Quantity', ItemRow.Inventory);
        ItemProperties.Add('UnitPrice', UnitPrice);
        ItemProperties.Add('UnitOfMeasureCode', ItemRow."Base Unit of Measure");
        exit(ItemProperties);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetUnitPrice(ItemNo: Text; VariantCode: Code[10]): Decimal;
    var
        ItemTable: Record Item;
        ProductType: Enum "Item Type";
        SalesPriceTable: Record "Sales Price";
        UnitPrice: Decimal;
        SalesType: Enum "Sales Price Type";
    begin
        // Set initial filters for sales price table
        SalesPriceTable.Reset();
        SalesPriceTable.SetRange("Item No.", ItemNo);
        SalesPriceTable.SetRange("Variant Code", VariantCode);
        SalesPriceTable.SetFilter("Sales Type", '<>%1', SalesType::Campaign);
        SalesPriceTable.SetFilter("Starting Date", '<=%1', Today());
        SalesPriceTable.SetFilter("Ending Date", '>=%1', Today());
        if SalesPriceTable.FindSet() then begin
            // Check if sales type Campaign exist, if not reset filter
            // SalesPriceTable.SetRange("Sales Type", SalesType::Campaign);
            // if Not SalesPriceTable.FindFirst() then begin
            //     SalesPriceTable.SetRange("Sales Type");
            // end;

            // Check if sales type filter is set if not then
            // Check sales type Customer exist, if not reset filter
            If SalesPriceTable.GetFilter("Sales Type") = '' then begin
                SalesPriceTable.SetRange("Sales Type", SalesType::Customer);
                if Not SalesPriceTable.FindFirst() then begin
                    SalesPriceTable.SetRange("Sales Type");
                end;
            end;

            // Check if sales type filter is set if not then
            // Check sales type Customer Price Group exist, if not reset filter
            If SalesPriceTable.GetFilter("Sales Type") = '' then begin
                SalesPriceTable.SetRange("Sales Type", SalesType::"Customer Price Group");
                if Not SalesPriceTable.FindFirst() then begin
                    SalesPriceTable.SetRange("Sales Type");
                end;
            end;

            // Check if sales type filter is set if not then
            // Check sales type All Customers exist, if not reset filter
            If SalesPriceTable.GetFilter("Sales Type") = '' then begin
                SalesPriceTable.SetRange("Sales Type", SalesType::"All Customers");
                if Not SalesPriceTable.FindFirst() then begin
                    SalesPriceTable.SetRange("Sales Type");
                end;
            end;

            If SalesPriceTable.GetFilter("Sales Type") <> '' then begin
                UnitPrice := SalesPriceTable."Unit Price";
            end else begin
                // Filter Item Record using Item No.
                ItemTable.Reset();
                ItemTable.SetRange(Type, ProductType::Inventory);
                ItemTable.SetRange("No.", ItemNo);
                if ItemTable.FindFirst() then begin
                    UnitPrice := ItemTable."Unit Price";
                end;
            end;
        end else begin
            // Filter Item Record using Item No.
            ItemTable.Reset();
            ItemTable.SetRange(Type, ProductType::Inventory);
            ItemTable.SetRange("No.", ItemNo);
            if ItemTable.FindFirst() then begin
                UnitPrice := ItemTable."Unit Price";
            end;
        end;
        exit(UnitPrice);
    end;
}