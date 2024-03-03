table 70501 "Lazada.OrderStatusTempTable"
{
    Caption = 'Lazada.OrderStatusTempTable';
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; companyid; Integer)
        {
            Caption = 'companyid';
            DataClassification = ToBeClassified;
        }
        field(2; domainType; Text[20])
        {
            Caption = 'domainType';
            DataClassification = ToBeClassified;
        }
        field(3; kti_sourcesalesorderid; Text[20])
        {
            Caption = 'kti_sourcesalesorderid';
            DataClassification = ToBeClassified;
        }
        field(4; orderstatus; Text[20])
        {
            Caption = 'orderstatus';
            DataClassification = ToBeClassified;
        }
        field(5; kti_orderstatus; Integer)
        {
            Caption = 'kti_orderstatus';
            DataClassification = ToBeClassified;
        }
        field(6; packageid; Text[20])
        {
            Caption = 'packageid';
            DataClassification = ToBeClassified;
        }
        field(7; tracking_number; Text[20])
        {
            Caption = 'tracking_number';
            DataClassification = ToBeClassified;
        }
        field(8; shipment_provider; Text[20])
        {
            Caption = 'shipment_provider';
            DataClassification = ToBeClassified;
        }
        field(9; pdf_url; Text[20])
        {
            Caption = 'pdf_url';
            DataClassification = ToBeClassified;
        }
        field(10; cancelreason; Text[20])
        {
            Caption = 'cancelreason';
            DataClassification = ToBeClassified;
        }
        field(11; kti_cancelreason; Integer)
        {
            Caption = 'kti_cancelreason';
            DataClassification = ToBeClassified;
        }
        field(12; kti_shipmentid; Text[20])
        {
            Caption = 'kti_shipmentid';
            DataClassification = ToBeClassified;
        }
        field(13; kti_salesorderid; Text[20])
        {
            Caption = 'kti_salesorderid';
            DataClassification = ToBeClassified;
        }
        field(14; kti_shipmentitemid; Text[20])
        {
            Caption = 'kti_shipmentitemid';
            DataClassification = ToBeClassified;
        }
        field(15; kti_salesorderitemid; Text[20])
        {
            Caption = 'kti_salesorderitemid';
            DataClassification = ToBeClassified;
        }
        field(16; kti_socialchannelorigin; Integer)
        {
            Caption = 'kti_socialchannelorigin';
            DataClassification = ToBeClassified;
        }
        field(17; kti_storecode; Text[20])
        {
            Caption = 'kti_storecode';
            DataClassification = ToBeClassified;
        }
        field(18; successful; Boolean)
        {
            Caption = 'successful';
            DataClassification = ToBeClassified;
        }
        field(19; laz_cancelReason; Integer)
        {
            Caption = 'laz_cancelReason';
            DataClassification = ToBeClassified;
        }
    }
}
