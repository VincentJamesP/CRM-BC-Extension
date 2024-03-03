report 60107 "Custom Sales Invoice 2"
{
    ApplicationArea = All;
    Caption = 'Custom Sales Invoice 2';
    UsageCategory = Administration;
    RDLCLayout = 'Source/Layout/CustomSalesInvoice2.rdl';
    DefaultLayout = RDLC;
    dataset
    {
        dataitem(SalesInvoiceHeader; "Sales Invoice Header")
        {
            column(No; "No.")
            {
            }
            column(SelltoCustomerNo; "Sell-to Customer No.")
            {
            }
            column(CustomerName; CustomerName)
            {
            }
            column(BusinessStyle; Customer."BII Business Style")
            {
            }
            column(CustomerAddress; CustomerAddress)
            {
            }
            column(CustomerTIN; Customer."VAT Registration No.")
            {
            }
            column(PaymentTerms; PaymentTerms.Description)
            {
            }
            column(DocumentDate; "Document Date")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(CustomerPhoneNo; Customer."Phone No.")
            {
            }
            column(ExemptSales; ExemptSales)
            {
            }
            column(ZeroRatedSales; ZeroRatedSales)
            {
            }
            column(VatableSales; VatableSales)
            {
            }
            column(TotalSalesVATInclusive; TotalSalesVATInclusive)
            {
            }
            column(LessVAT; LessVAT)
            {
            }
            column(AmountNetOfVAT; AmountNetOfVAT)
            {
            }
            column(TotalAmountDues; TotalAmountDues)
            {
            }
            column(Preparedby; Preparedby)
            {
            }
            column(Approvedby; Approvedby)
            {
            }
            column(External_Document_No_; "External Document No.")
            {
            }
            dataitem(SalesInvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = SalesInvoiceHeader;
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(Quantity; Quantity)
                {
                }
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                {
                }
                column(Description; Description)
                {
                }
                column(Unit_Price; "Unit Price")
                {
                }
                column(Amount; Amount)
                {
                }
                column(Amount_Including_VAT_Line; "Amount Including VAT")
                {
                }
                column(IsGL; IsGL)
                {
                }
                column(DimensionValueName; DimensionValueName)
                {
                }
                trigger OnAfterGetRecord()
                var
                    DimSetEntry: Record "Dimension Set Entry";
                    DimensionValue: Record "Dimension Value";
                begin
                    DimensionValueName := '';
                    IsGL := false;
                    if Type = Type::"G/L Account" then begin
                        IsGL := true;

                        DimSetEntry.SetRange("Dimension Set ID", "Dimension Set ID");
                        DimSetEntry.SetRange("Dimension Code", 'CUSTOMERPAYMENT');
                        if DimSetEntry.FindSet() then begin
                            DimensionValue.SetRange(Code, DimSetEntry."Dimension Value Code");
                            if DimensionValue.FindSet() then
                                DimensionValueName := DimensionValue.Name;
                        end;
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                GetVat;
                GetCustomer;
                GetAssignatories;
                GetTotals;
                GetPaymentTerms;

                if "Sell-to Contact" <> '' then
                    CustomerName := "Sell-to Contact"
                else
                    CustomerName := "Sell-to Customer Name";

                CustomerAddress := SalesInvoiceHeader."Sell-to Address" + ' ' + SalesInvoiceHeader."Sell-to Address 2" + ' ' + SalesInvoiceHeader."Sell-to City" + ' ' + SalesInvoiceHeader."Sell-to County" + ' ' + SalesInvoiceHeader."Sell-to Post Code";

                // Contact.SetRange("No.", "Sell-to Contact No.");
                // if Contact.FindSet() then begin
                //     CustomerName := Contact.Name;
                //     CustomerAddress := Contact.Address + ' ' + Contact."Address 2" + ' ' + Contact.City + ' ' + Contact.County + ' ' + Contact."Country/Region Code";
                // end else begin
                //     CustomerName := Customer.Name;
                //     CustomerAddress := Customer.Address + ' ' + Customer."Address 2" + ' ' + Customer.City + ' ' + Customer.County + ' ' + Customer."Country/Region Code";
                // end;
            end;

        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    local procedure GetVat()
    var
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        if VATEntry.FindSet() then
            repeat
                VATPostingSetup.Reset();
                VATPostingSetup.SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
                VATPostingSetup.SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
                if VATPostingSetup.FindSet() then begin
                    if VATPostingSetup."PHT_VAT Type" = VATPostingSetup."PHT_VAT Type"::"Exempt Sales" then
                        ExemptSales += VATEntry.Amount
                    else
                        if VATPostingSetup."PHT_VAT Type" = VATPostingSetup."PHT_VAT Type"::"Exempt Sales" then
                            ZeroRatedSales += VATEntry.Amount else
                            if VATPostingSetup."PHT_VAT Type" = VATPostingSetup."PHT_VAT Type"::"Exempt Sales" then
                                VatableSales += VATEntry.Amount;
                end;
            until VATEntry.Next() = 0;
    end;

    local procedure GetCustomer()
    begin
        Customer.SetRange("No.", SalesInvoiceHeader."Sell-to Customer No.");
        if Customer.FindSet() then
            exit;
        exit;
    end;

    local procedure GetPaymentTerms()
    begin
        PaymentTerms.SetRange(Code, SalesInvoiceHeader."Payment Terms Code");
        if PaymentTerms.FindSet() then
            exit;
        exit;
    end;

    local procedure GetTotals()
    begin
        DiscountAmount := SalesInvoiceHeader."Invoice Discount Amount";
        SalesInvLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                TotalSalesVATInclusive += SalesInvLine."Amount Including VAT";

                if SalesInvLine."Amount Including VAT" <> 0 then
                    LessVAT += (SalesInvLine."Amount Including VAT" - SalesInvLine.Amount);

                AmountNetOfVAT += SalesInvLine.Amount;
                DiscountAmount += SalesInvoiceLine."Line Discount Amount";
            until SalesInvLine.Next() = 0;
        LessVAT := abs(LessVAT);
        AmountNetOfVAT := abs(AmountNetOfVAT);
        DiscountAmount := abs(DiscountAmount);
        TotalAmountDues := abs(AmountNetOfVAT);
    end;

    local procedure ApprovalEntryValue(var DocumentNo: Code[20]; var ApprovalEntryParameter: Record "Posted Approval Entry")
    begin
        ApprovalEntryParameter.Reset();
        ApprovalEntryParameter.SetRange("Document No.", DocumentNo);
        if not ApprovalEntryParameter.FindSet() then
            exit;
    end;

    local procedure UserValue(var IDParameter: Code[50]; var UserParameter: Record User)
    begin
        UserParameter.Reset();
        UserParameter.SetRange("User Name", IDParameter);
        if not UserParameter.FindSet() then
            exit;
    end;

    local procedure GetAssignatories()
    begin
        Clear(PreparedBy);
        Clear(ApprovedBy);


        Clear(User);
        UserValue(SalesInvoiceHeader."User ID", User);
        PreparedBy := User."Full Name";

        Clear(ApprovalEntry);
        ApprovalEntryValue(SalesInvoiceHeader."No.", ApprovalEntry);

        Clear(User);
        UserValue(ApprovalEntry."Approver ID", User);
        ApprovedBy := User."Full Name";
    end;


    var
        VatableSales: Decimal;
        ZeroRatedSales: Decimal;
        ExemptSales: Decimal;
        Customer: Record Customer;
        PaymentTerms: Record "Payment Terms";
        TotalSalesVATInclusive: Decimal;
        LessVAT: Decimal;
        TotalAmountDues: Decimal;
        SalesInvLine: Record "Sales Invoice Line";
        AmountNetOfVAT: Decimal;
        DiscountAmount: Decimal;
        Preparedby: Text[100];
        Approvedby: Text[100];
        User: Record User;
        ApprovalEntry: Record "Posted Approval Entry";
        IsGL: Boolean;
        DimensionValueName: Text;
        Contact: Record Contact;
        CustomerName: Text[100];
        CustomerAddress: Text[100];
}
