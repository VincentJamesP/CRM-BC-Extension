codeunit 70400 "Moo.InventoryController" implements "Moo.IController"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Create(functionID: Integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.InventoryFunctionEnum";
    begin
        functionsEnum := Enum::"Moo.InventoryFunctionEnum".FromInteger(functionID);
        case functionsEnum of
            functionsEnum::InventoryReceipt:
                begin
                    exit(InventoryReceipt(object));
                end;
            functionsEnum::InventoryShipment:
                begin
                    exit(InventoryShipment(object));
                end;
            functionsEnum::PostTransferShipmentPostTransferReceipt:
                begin
                    exit(PostTransferShipmentPostTransferReceipt(object));
                end;
            functionsEnum::PostTransferReceipt:
                begin
                    exit(PostTransferReceipt(object));
                end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Retrieve(functionID: Integer; object: Text): Text
    var
        functionsEnum: Enum "Moo.InventoryFunctionEnum";
    begin
        functionsEnum := Enum::"Moo.InventoryFunctionEnum".FromInteger(functionID);
        case functionsEnum of
            functionsEnum::GetProductsAvailabilityByStore:
                begin
                    exit(GetProductsAvailabilityByStore(object));
                end;
            functionsEnum::GetProductSerialsAvailabilityByStore:
                begin
                    exit(GetProductSerialsAvailabilityByStore(object));
                end;
            functionsEnum::GetBin:
                begin
                    exit(GetBin(object));
                end;
            functionsEnum::GetProductsByStore:
                begin
                    exit(GetProductsByStore(object));
                end;
            functionsEnum::GetBarcode:
                begin
                    exit(GetBarcode(object));
                end;
            functionsEnum::GetLocations:
                begin
                    exit(GetLocations(object));
                end;
            functionsEnum::GetShipmentsByLocation:
                begin
                    exit(GetShipmentsByLocation(object));
                end;
            functionsEnum::GetReceiptsByLocation:
                begin
                    exit(GetReceiptsByLocation(object));
                end;
            functionsEnum::GetPostedTransferShipment:
                begin
                    exit(GetPostedTransferShipment(object));
                end;
            functionsEnum::GetTransferOrdersByOrigin:
                begin
                    exit(GetTransferOrdersByOrigin(object));
                end;
        end;
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Update(functionID: Integer; object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure Delete(functionID: Integer; object: Text): Text
    begin

    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetProductsAvailabilityByStore(jsonData: Text): Text
    var
        inventoryDomain: Codeunit "Moo.InventoryDomain";
        inventoryAvailability: Text;
    begin
        inventoryAvailability := inventoryDomain.Retrieve(jsonData);
        exit(inventoryAvailability);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetProductSerialsAvailabilityByStore(jsonData: Text): Text
    var
        serialNoTrackingDomain: Codeunit "Moo.SerialNoTrackingDomain";
        serialNumberValidity: Text;
    begin
        serialNumberValidity := serialNoTrackingDomain.Retrieve(jsonData);

        exit(serialNumberValidity);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetBin(jsonData: Text): Text
    var
        BinDomain: Codeunit "Moo.BinDomain";
        BinTemp: Record "Moo.BinTempTable" temporary;
        Cnt: Integer;
    begin
        exit(BinDomain.RetrieveByBin(jsonData, BinTemp));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure InventoryShipment(jsonData: Text): Text
    var
        stockShipmentDomain: Codeunit "Moo.StockShipmentDomain";
        stockShipment: Text;
        PostedShipments: JsonArray;
        ResponseValue: Text;
    begin
        stockShipment := stockShipmentDomain.Create(jsonData);
        PostedShipments := stockShipmentDomain.PostStockShipment(stockShipment);
        PostedShipments.WriteTo(ResponseValue);
        exit(ResponseValue);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure InventoryReceipt(jsonData: Text): Text
    var
        stockReceiptDomain: Codeunit "Moo.StockReceiptDomain";
        StockReceipt: Text;
        PostedReceipts: JsonArray;
        ResponseValue: Text;
    begin
        StockReceipt := stockReceiptDomain.Create(jsonData);
        PostedReceipts := stockReceiptDomain.PostStockReceipt(StockReceipt);
        PostedReceipts.WriteTo(ResponseValue);
        exit(ResponseValue);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetProductsByStore(jsonData: Text): Text
    var
        ProductDomain: Codeunit "Moo.ProductDomain";
        Products: Text;
    begin
        Products := ProductDomain.Retrieve(jsonData);
        exit(Products);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetBarcode(jsonData: Text): Text
    var
        BarcodeDomain: Codeunit "Moo.BarcodeDomain";
        Barcodes: Text;
    begin
        Barcodes := BarcodeDomain.Retrieve(jsonData);
        exit(Barcodes);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetLocations(jsonData: Text): Text
    var
        LocationDomain: Codeunit "Moo.LocationDomain";
        LocationTemp: Record "Moo.LocationTempTable" temporary;
        Cnt: Integer;
    begin
        exit(LocationDomain.RetrieveByLocation(jsonData, LocationTemp));
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetShipmentsByLocation(jsonData: Text): Text
    var
        InvtDocDomain: Codeunit "Moo.InventoryDocDomain";
        DocType: Enum "Invt. Doc. Document Type";
        InvtShipmentDocuments: Text;
    begin
        InvtShipmentDocuments := InvtDocDomain.GetDocumentsByDocType(DocType::Shipment, jsonData);
        exit(InvtShipmentDocuments);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetReceiptsByLocation(jsonData: Text): Text
    var
        InvtDocDomain: Codeunit "Moo.InventoryDocDomain";
        DocType: Enum "Invt. Doc. Document Type";
        InvtReceiptDocuments: Text;
    begin
        InvtReceiptDocuments := InvtDocDomain.GetDocumentsByDocType(DocType::Receipt, jsonData);
        exit(InvtReceiptDocuments);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetPostedTransferShipment(jsonData: Text): Text
    var
        TransferShipmentDomain: Codeunit "Moo.TransferShipmentDomain";
        PostedTransferShipmentDocs: Text;
    begin
        PostedTransferShipmentDocs := TransferShipmentDomain.Retrieve(jsonData);
        exit(PostedTransferShipmentDocs);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure PostTransferReceipt(jsonData: Text): Text
    var
        TransferReceiptDomain: Codeunit "Moo.TransferReceiptDomain";
        PostedTransferReceipt: Text;
    begin
        PostedTransferReceipt := TransferReceiptDomain.Create(jsonData);
        exit(PostedTransferReceipt);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure GetTransferOrdersByOrigin(jsonData: Text): Text
    var
        TransferOrderDomain: Codeunit "Moo.TransferOrderDomain";
        TransferOrders: Text;
    begin
        TransferOrders := TransferOrderDomain.Retrieve(jsonData);
        exit(TransferOrders);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure PostTransferShipmentPostTransferReceipt(jsonData: Text): Text
    var
        TransferOrderDomain: Codeunit "Moo.TransferOrderDomain";
        PostedTransferReceipt: Text;
    begin
        PostedTransferReceipt := TransferOrderDomain.Create(jsonData);
        exit(PostedTransferReceipt);
    end;
}
