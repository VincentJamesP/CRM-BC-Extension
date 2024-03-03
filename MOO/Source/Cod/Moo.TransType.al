enum 70150 "Moo.TransType" implements "Moo.IController"
{
    Extensible = true;

    value(0; SalesInvoice)
    {
        Implementation = "Moo.IController" = "Moo.InvoiceController";
    }
    value(1; SalesOrder)
    {
        Implementation = "Moo.IController" = "Moo.SalesOrderController";
    }
    value(2; InventoryMovement)
    {
        Implementation = "Moo.IController" = "Moo.InventoryController";
    }
    value(3; WarehouseShipment)
    {
        Implementation = "Moo.IController" = "Moo.WhseShipmentController";
    }
    value(4; Price)
    {
        Implementation = "Moo.IController" = "Moo.PriceController";
    }
}
