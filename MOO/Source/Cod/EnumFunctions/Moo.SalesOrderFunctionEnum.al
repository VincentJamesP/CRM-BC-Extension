enum 70152 "Moo.SalesOrderFunctionEnum"
{
    Extensible = true;

    value(0; CreateSO)
    {
        Caption = 'CreateSO';
    }
    value(1; CreateSOwithPaymentLines)
    {
        Caption = 'CreateSOwithPaymentLines';
    }
    value(2; CreateSOwithPaymentandItemTracking)
    {
        Caption = 'CreateSOwithPaymentandItemTracking';
    }
    value(3; CreateSOwithPaymentandWhseShipment)
    {
        Caption = 'CreateSOwithPaymentandWhseShipment';
    }
}
