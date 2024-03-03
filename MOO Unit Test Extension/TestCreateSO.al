
codeunit 80002 "Test - Create SO"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Source: Text;
        TransType: Integer;
        FunctionType: Integer;
        JSONData: Text;
        MooAPI: Codeunit "Moo.API";
        Order_Header: JsonArray;
        Order_HeaderOBJ: JsonObject;
        Order_Line: JsonArray;
        Order_LineOBJ: JsonObject;
        Payment_Method: JsonArray;
        Payment_MethodOBJ: JsonObject;
        Tender_Type: JsonArray;
        Tender_TypeOBJ: JsonObject;
        Order_Details: JsonObject;
        Response: Text;

    trigger OnRun()
    begin
        Source := 'LAZADA';
        TransType := 1; // Sales Order
        FunctionType := 3; // CreateSOwithPaymentandWhseShipment
        // Generate sample JSON Data
        // Order Header
        Order_HeaderOBJ.Add('kti_sourcesalesorderid', '601602448655852');
        Order_HeaderOBJ.Add('CustNo', '20000');
        Order_HeaderOBJ.Add('warehouse', 'WLLF01');
        Order_Header.Add(Order_HeaderOBJ);

        // Order Line
        Order_LineOBJ.Add('kti_sourcesalesorderid', '601602448655852');
        Order_LineOBJ.Add('ItemNo', 'COF0095');
        Order_LineOBJ.Add('VariantCode', '');
        Order_LineOBJ.Add('Quantity', '1');
        Order_LineOBJ.Add('UnitofMeasureCode', 'PCS');
        Order_LineOBJ.Add('kti_sourcesalesorderitemid', '601602448755852');
        Order_Line.Add(Order_LineOBJ);

        // Tender Type
        Tender_TypeOBJ.Add('TRN', '123');
        Tender_TypeOBJ.Add('code', 'CA');
        Tender_TypeOBJ.Add('amount', 100);
        Tender_Type.Add(Tender_TypeOBJ);
        Clear(Tender_TypeOBJ);
        Tender_TypeOBJ.Add('TRN', '123');
        Tender_TypeOBJ.Add('code', 'CC');
        Tender_TypeOBJ.Add('amount', 300);
        Tender_Type.Add(Tender_TypeOBJ);

        // Payment Method
        Payment_MethodOBJ.Add('kti_sourcesalesorderid', '601602448655852');
        Payment_MethodOBJ.Add('tender_type', Tender_Type);
        Payment_Method.Add(Payment_MethodOBJ);

        // JSON Data
        Order_Details.Add('order_header', Order_Header);
        Order_Details.Add('order_line', Order_Line);
        Order_Details.Add('payment_method', Payment_Method);
        Order_Details.WriteTo(JSONData);
    end;

    [Test]
    procedure TestAPIResponse()
    begin
        Response := MooAPI.Create(Source, TransType, FunctionType, JSONData);
        asserterror TestFieldIfEmpty(Response);
    end;

    local procedure TestFieldIfEmpty(FieldValue: Text)
    begin
        if FieldValue <> '' then
            Error(FieldValue);
    end;
}
