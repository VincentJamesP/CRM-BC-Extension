codeunit 70504 "Lazada.OrderStatusModel"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure BuildOrderPackedPayload(companyid: Text; PickNo: Code[20]): JsonObject
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        JO: JsonObject;
        RegisteredWhseActHdr: Record "Registered Whse. Activity Hdr.";
        RegisteredWhseActLine: Record "Registered Whse. Activity Line";
        OrderStatusTempTable: Record "Lazada.OrderStatusTempTable" temporary;
        LocationRec: Record Location;
        SH: Record "Sales Header";
        SL: Record "Sales Line";
        domainType: Text;
        kti_sourcesalesorderid: Text;
        kti_storecode: Text;
        itemidsJArray: JsonArray;
    begin

        RegisteredWhseActHdr.SetRange(Type, RegisteredWhseActHdr.Type::Pick);
        RegisteredWhseActHdr.SetRange("Whse. Activity No.", PickNo);
        if RegisteredWhseActHdr.FindFirst() then begin
            LocationRec.Get(RegisteredWhseActHdr."Location Code");
            kti_storecode := LocationRec."Moo Channel Code";
            RegisteredWhseActLine.SetRange("Activity Type", RegisteredWhseActLine."Activity Type"::Pick);
            RegisteredWhseActLine.SetRange("No.", RegisteredWhseActHdr."No.");
            if RegisteredWhseActLine.FindFirst() then
                repeat
                    SH.SetRange("Document Type", SH."Document Type"::Order);
                    SH.SetRange("No.", RegisteredWhseActLine."Source No.");
                    if SH.FindFirst() then begin
                        kti_sourcesalesorderid := SH."Moo Source Sales Order ID";
                        SL.SetRange("Document Type", SL."Document Type"::Order);
                        SL.SetRange("Document No.", SH."No.");
                        if SL.FindFirst() then
                            repeat
                                itemidsJArray.Add(SL."Moo Source Sales Order Item ID");
                            until SL.Next() = 0;
                    end;
                until RegisteredWhseActLine.Next() = 0;
        end;
        JO.Add('companyid', companyid);
        JO.Add('domainType', domainType);
        JO.Add('kti_storecode', kti_storecode);
        JO.Add('kti_sourcesalesorderid', kti_sourcesalesorderid);
        JO.Add('kti_sourcesalesorderitemids', itemidsJArray);
        exit(JO);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure BuildOrderForDispatchPayload(companyid: Text; WhseShipHdr: Record "Warehouse Shipment Header"): JsonObject
    var
        HelperDomain: Codeunit "Moo.HelperDomain";
        JO: JsonObject;
        PostedWhseShipmentHdr: Record "Posted Whse. Shipment Header";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        OrderStatusTempTable: Record "Lazada.OrderStatusTempTable" temporary;
        LocationRec: Record Location;
        SH: Record "Sales Header";
        SL: Record "Sales Line";
        domainType: Text;
        kti_sourcesalesorderid: Text;
        kti_storecode: Text;
        itemidsJArray: JsonArray;
        packageid: Text;
    begin
        packageid := WhseShipHdr."Moo Package ID";
        LocationRec.Get(WhseShipHdr."Location Code");
        kti_storecode := LocationRec."Moo Channel Code";
        PostedWhseShipmentLine.SetRange("Whse. Shipment No.", WhseShipHdr."No.");
        if PostedWhseShipmentLine.FindFirst() then
            repeat
                SH.SetRange("Document Type", SH."Document Type"::Order);
                SH.SetRange("No.", PostedWhseShipmentLine."Source No.");
                if SH.FindFirst() then begin
                    kti_sourcesalesorderid := SH."Moo Source Sales Order ID";
                    SL.SetRange("Document Type", SL."Document Type"::Order);
                    SL.SetRange("Document No.", SH."No.");
                    if SL.FindFirst() then
                        repeat
                            itemidsJArray.Add(SL."Moo Source Sales Order Item ID");
                        until SL.Next() = 0;
                end;
            until PostedWhseShipmentLine.Next() = 0;

        JO.Add('companyid', companyid);
        JO.Add('packageid', packageid);
        JO.Add('kti_storecode', kti_storecode);
        JO.Add('kti_sourcesalesorderid', kti_sourcesalesorderid);
        JO.Add('kti_sourcesalesorderitemids', itemidsJArray);
        exit(JO);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure UpdateWhseShipment(RegisteredPickNo: Text;
            packageid: Text;
            shipment_provider: Text;
            tracking_number: Text)
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        RegWhseActLine: Record "Registered Whse. Activity Line";
    begin
        RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
        RegWhseActLine.SetRange("No.", RegisteredPickNo);
        if RegWhseActLine.FindFirst() then begin
            WhseShipmentHdr.SetRange("No.", RegWhseActLine."Whse. Document No.");
            if WhseShipmentHdr.FindFirst() then begin
                WhseShipmentHdr."Moo Package ID" := packageid;
                WhseShipmentHdr."Moo Shipment Provider" := shipment_provider;
                WhseShipmentHdr."Moo Tracking Number" := tracking_number;
                WhseShipmentHdr.Modify();
            end;
        end;
    end;
}
