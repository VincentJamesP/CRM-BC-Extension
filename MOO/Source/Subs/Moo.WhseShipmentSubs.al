codeunit 70185 "Moo.Whse Shipment Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforePostedWhseShptHeaderInsert', '', false, false)]
    local procedure OnBeforePostedWhseShptHeaderInsert(var PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        PostedWhseShipmentHeader."Moo Package ID" := WarehouseShipmentHeader."Moo Package ID";
        PostedWhseShipmentHeader."Moo Shipment Provider" := WarehouseShipmentHeader."Moo Shipment Provider";
        PostedWhseShipmentHeader."Moo Tracking Number" := WarehouseShipmentHeader."Moo Tracking Number";
        PostedWhseShipmentHeader."Moo AWB URL" := WarehouseShipmentHeader."Moo AWB URL";
    end;
}
