codeunit 70506 "Lazada.CancelOrderSubs"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        JsonObj: JsonObject;
        JsonText: Text;
        logText: Text;
        APIHelper: Codeunit "Moo.API Management Domain";
        APIMethod: Enum "Moo.API Method Enum";
        APIChannel: Enum "Moo.API Channel";
        APIFunction: Enum "Moo.APIFunctionsEnum";
        APIList: Record "Moo. API Header";
        CancelOrderModel: Codeunit "Lazada.CancelOrderModel";
        SalesLine: Record "Sales Line";
        InvoiceNo: Text;
        SearchKeyword: Text;
        InvoiceNoComment: Text;
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then begin
            APIList := APIHelper.GetAPIHeader(APIChannel::Lazada);

            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::" ");
            SearchKeyword := 'Invoice No.';
            if SalesLine.FindSet() then begin
                // Get Invoice No
                repeat
                    InvoiceNoComment := SalesLine.Description;
                    if (InvoiceNoComment.ToLower().Contains(SearchKeyword.ToLower())) then begin
                        InvoiceNo := InvoiceNoComment.Substring(Text.StrLen(SearchKeyword) + 2, 6);
                        break;
                    end;
                until SalesLine.Next() = 0;
            end;

            // Map request headers to JsonObject
            JsonObj := CancelOrderModel.MapRequestHeaders(APIList."Company ID", SalesHeader."Sell-to Customer No.", InvoiceNo);
            JsonObj.WriteTo(JsonText);

            // Call API
            logText := APIHelper.CallWebservice(APIChannel::Lazada, APIFunction::LazadaOrderStatusCancelOrder, JSONText, APIMethod::POST);
        end;
    end;
}
