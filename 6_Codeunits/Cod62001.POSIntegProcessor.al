/// <summary>
/// CodeunitPOSIntegProcessor (ID 62001).
/// </summary>
codeunit 62001 POSIntegProcessor
{
    trigger OnRun()
    var
        RecRef: RecordRef;
        RecID: RecordId;
        SalesHeader: Record "Sales Header";
        POSSalesHeader: Record POSSalesHeader;
    begin
        RecID := StartRecID;
        RecRef := RecID.GetRecord();

        case ActionType of
            ActionType::CREATESALESDOCUMENTS:
                begin
                    RecRef.SetTable(POSSalesHeader);
                    POSSalesHeader.Find('=');
                    CreateSalesDocument(POSSalesHeader);
                end;
            ActionType::POSTDOCUMENTS:
                begin
                    RecRef.SetTable(SalesHeader);
                    if SalesHeader.Find('=') then
                        PostSalesDocument(SalesHeader);
                end;
        end;
    end;

    var
        StartRecID: RecordId;
        ActionType: Enum POSActType;
        Text001: Label '%1 must not be blank.';
        Text002: Label '%1 cannot be processed because %2 is %3 of %4 %5.';
        Text003: Label 'Transaction No. %1 doesnt exists';

    local procedure PostSalesDocument(SalesHeader: Record "Sales Header")
    begin
        Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
    end;

    local procedure CreateSalesDocument(var POSSalesHeader: Record POSSalesHeader)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        POSSetup: Record "POS Integration Setup";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        Location: Record Location;
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LastLineNo: Integer;
    begin
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", POSSalesHeader."Document Type");
        SalesHeader."No." := POSSalesHeader."No.";
        SalesHeader.Insert(true);
        Customer.Get(POSSalesHeader."Sell-to Customer No.");

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        if POSSalesHeader."Order Date" <> 0D then begin
            SalesHeader.Validate("Order Date", POSSalesHeader."Order Date");
            SalesHeader.Validate("Document Date", POSSalesHeader."Order Date");
            SalesHeader.Validate("Posting Date", POSSalesHeader."Posting Date");

        end;

        SalesHeader.CreateDim(
          Database::Customer, SalesHeader."Bill-to Customer No.",
          Database::"Salesperson/Purchaser", SalesHeader."Salesperson Code",
          Database::Campaign, SalesHeader."Campaign No.",
          Database::"Responsibility Center", SalesHeader."Responsibility Center",
          Database::"Customer Templ.", SalesHeader."Bill-to Customer Templ. Code");

        if POSSalesHeader."Posting No." = '' then begin
            SalesSetup.Get;
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
                SalesHeader."Posting No." :=
                  NoSeriesMgt.GetNextNo(
                    SalesSetup."Posted Credit Memo Nos.", SalesHeader."Posting Date", true)
            else
                SalesHeader."Posting No." := NoSeriesMgt.GetNextNo(SalesSetup."Posted Invoice Nos.", SalesHeader."Posting Date", true);
            SalesHeader."Posting No. Series" := SalesSetup."Posted Invoice Nos.";
        end else
            SalesHeader."Posting No." := POSSalesHeader."Posting No.";

        SalesHeader.Validate("Payment Method Code", '');
        SalesHeader.Validate("Reason Code", POSSetup."Sales Doc. Reason Code");
        SalesHeader.Validate("Payment Discount %", 0);

        SalesHeader.Validate("Bill-to Customer No.", POSSalesHeader."Bill-to Customer No.");
        SalesHeader.Modify(true);
        CreateSalesLines(POSSalesHeader, SalesHeader);

        POSSalesHeader.Status := POSSalesHeader.Status::"Document Created";
        POSSalesHeader."Transaction Time" := CurrentDateTime;
        POSSalesHeader."Document No." := SalesHeader."No.";
        POSSalesHeader.Modify(true);

        CopyToPostedTransfered(POSSalesHeader);
    end;

    local procedure CreateSalesLines(POSSalesHeader: Record POSSalesHeader; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        POSSalesLine: Record POSSalesLine;
        VATPostingSetup: Record "VAT Posting Setup";
        LineNo: Integer;
    begin
        POSSalesLine.SetRange("Document Type", POSSalesHeader."Document Type");
        POSSalesLine.SetRange("Document No.", POSSalesHeader."No.");
        if POSSalesLine.FindSet() then
            repeat
                SalesLine.Init();
                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                LineNo += 10000;
                SalesLine."Line No." := LineNo;
                SalesLine.Insert(true);

                case POSSalesLine.Type of
                    POSSalesLine.Type::"G/L Account":
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                    POSSalesLine.Type::Item:
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                    POSSalesLine.Type::"Fixed Asset":
                        SalesLine.Validate(Type, SalesLine.Type::"Fixed Asset");
                    POSSalesLine.Type::"Charge (Item)":
                        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
                end;

                SalesLine.Validate("No.", POSSalesLine."No.");
                SalesLine.Validate("Location Code", POSSalesLine."Location Code");
                SalesLine.Validate(Quantity, POSSalesLine.Quantity);
                SalesLine.Validate("Line Discount Amount", 0);
                SalesLine."Unit Price" := POSSalesLine."Unit Price";
                SalesLine.Modify(true);

            until POSSalesLine.Next() = 0;
    end;
    /// <summary>
    /// SetActionType.
    /// </summary>
    /// <param name="TempActionType">EnumPOSActType.</param>
    /// <param name="TempRecIDI">RecordId.</param>
    procedure SetActionType(TempActionType: Enum POSActType; TempRecIDI: RecordId)
    begin
        ActionType := TempActionType;
        StartRecID := TempRecIDI;
    end;

    local procedure CopyToPostedTransfered(POSSalesHeader: Record POSSalesHeader)
    var
        POSSalesLine: Record POSSalesLine;
        POSSalesHeaderTransf: Record POSSalesHeaderTransf;
        POSSalesLinesTransf: Record POSSalesLineTransf;
    begin
        POSSalesHeaderTransf.TransferFields(POSSalesHeader);
        if POSSalesHeaderTransf.Insert(true) then;

        POSSalesLine.Reset();
        POSSalesLine.SetRange("Document Type", POSSalesHeader."Document Type");
        POSSalesLine.SetRange("Document No.", POSSalesHeader."No.");
        if POSSalesLine.FindSet() then
            repeat
                Clear(POSSalesLinesTransf);
                POSSalesLinesTransf.TransferFields(POSSalesLine);
                if POSSalesLinesTransf.Insert(true) then;
            until POSSalesLine.Next() = 0;
    end;
}
