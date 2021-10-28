/// <summary>
/// CodeunitPOSOperations (ID 62000).
/// </summary>
codeunit 62000 POSOperations
{
    trigger OnRun()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecID: RecordId;
    begin
        JobQueueEntry.SetFilter(ID, '<>%1', JobQueueEntry.ID);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        if JobQueueEntry.FindSet() then begin
            LogError(RecID, Text001);
            exit;
        end;
        case
            JobQueueEntry."Parameter String" of
            'POSSALES':
                TransferSales;
            'PAYMENTS':
                TransferPayments;
        end;
    end;

    var
        ActionType: Enum POSActType;
        Text001: Label 'The job has been skipped due to overlap with other processes.';
        Text002: Label 'The %1 processing has been skipped because the document with %2=%3, %4=%5 not found.';

    local procedure TransferSales()
    var
        POSIntegSetup: Record "POS Integration Setup";
        SalesHeader: Record "Sales Header";
    begin
        POSIntegSetup.Get();
        ActionType := ActionType::CREATESALESDOCUMENTS;
        CreateSalesDocuments;

        ActionType := ActionType::POSTDOCUMENTS;
        IF POSIntegSetup."Automatic Sales Procesor" THEN
            PostSalesDocuments;

        IF POSIntegSetup."Delete Procesed Line" THEN
            DeleteSales(POSIntegSetup."Automatic Sales Procesor");
    end;

    local procedure CreateSalesDocuments()
    var
        POSHeader: Record POSSalesHeader;
    begin

        POSHeader.SetCurrentKey("Document Type", Status);
        POSHeader.Ascending(false);
        POSHeader.SetRange(Status, POSHeader.Status::New);
        if POSHeader.FindFirst() then
            repeat
                CreateSalesDocument(POSHeader);
            until POSHeader.Next() = 0;
    end;

    local procedure CreateSalesDocument(POSHeader: Record POSSalesHeader)
    var
        RecRef: RecordRef;
        WasSuccess: Boolean;
        ErrorLogEntryNo: Integer;
        CUPOSTaskProcessor: Codeunit POSIntegProcessor;
    begin
        RecRef.GetTable(POSHeader);
        Commit();
        CUPOSTaskProcessor.SetActionType(ActionType, RecRef.RecordId);
        WasSuccess := CUPOSTaskProcessor.Run();
        if not WasSuccess then begin
            LogError(RecRef.RecordId, CopyStr(GetLastErrorText, 1, 250));
            ClearLastError();
            POSHeader.Status := POSHeader.Status::Error;
            POSHeader.Modify();
        end;
        Commit();
    end;

    local procedure PostSalesDOcuments()
    var
        SalesHeader: Record "Sales Header";
        POSHeader: Record POSSalesHeader;
        RecRef: RecordRef;
        Found: Boolean;
    begin
        POSHeader.SetCurrentKey("Document Type", Status);
        POSHeader.Ascending(false);
        POSHeader.SetRange(Status, POSHeader.Status::"Document Created");
        if POSHeader.FindFirst() then
            repeat
                Found := SalesHeader.Get(POSHeader."Document Type", POSHeader."Document No.");
                IF Found then
                    PostSalesDocument(SalesHeader, POSHeader)
                else begin
                    RecRef.GetTable(POSHeader);
                    SalesHeader."Document Type" := POSHeader."Document Type";
                    LogError(
                      RecRef.RecordId,
                      StrSubstNo(Text002, POSHeader.TableCaption, SalesHeader.FieldCaption("Document Type"),
                        SalesHeader."Document Type", SalesHeader.FieldCaption("No."), POSHeader."Document No."));

                    POSHeader.Status := POSHeader.Status::Error;
                    POSHeader."Transaction Time" := CurrentDateTime;
                    POSHeader.Modify();
                end;
            until POSHeader.Next() = 0;
    end;

    local procedure PostSalesDocument(SalesHeader: Record "Sales Header"; POSHeader: Record POSSalesHeader)
    var
        RecRef: RecordRef;
        WasSuccess: Boolean;
        PostingDocNo: Code[20];
        ErrorLogEntryNo: Integer;
        CUPOSTaskProcessor: Codeunit POSIntegProcessor;
    begin
        PostingDocNo := SalesHeader."Posting No.";
        RecRef.GetTable(SalesHeader);
        Commit();
        CUPOSTaskProcessor.SetActionType(ActionType, RecRef.RecordId);
        WasSuccess := CUPOSTaskProcessor.Run();
        IF WasSuccess then begin
            POSHeader.Status := POSHeader.Status::Posted;
            POSHeader."Transaction Time" := CurrentDateTime;
            POSHeader."Document No." := PostingDocNo;
            POSHeader.Modify();
        end else begin
            RecRef.GetTable(POSHeader);
            LogError(RecRef.RecordId, CopyStr(GetLastErrorText, 1, 250));
            ClearLastError();
            POSHeader.Status := POSHeader.Status::Error;
            POSHeader."Transaction Time" := CurrentDateTime;
            POSHeader.Modify();
        end;
        Commit();
    end;

    local procedure LogError(RecID: RecordId; Message: Text[250])
    var
        LogEntry: Record POSIntegErrorLog;
    begin
        LogEntry.Init();
        LogEntry."User ID" := UserId;
        LogEntry."Entry Date/Time" := CurrentDateTime;
        LogEntry."Error Message" := Message;
        LogEntry."Record Identifier" := RecId;
        case ActionType of
            ActionType::CREATESALESDOCUMENTS:
                LogEntry."Operation Type" := LogEntry."Operation Type"::"Process Transaction";
            ActionType::POSTDOCUMENTS:
                LogEntry."Operation Type" := LogEntry."Operation Type"::"Post Document";
        end;
        LogEntry.Insert(true);
    end;

    local procedure DeleteSales(NeedPost: Boolean)
    var
        POSSalesHeader: Record POSSalesHeader;
        POSSalesLines: Record POSSalesLine;
    begin
        POSSalesHeader.Reset();
        if NeedPost then
            POSSalesHeader.SetRange(POSSalesHeader.Status, POSSalesHeader.Status::Posted)
        else
            POSSalesHeader.SetRange(POSSalesHeader.Status, POSSalesHeader.Status::"Document Created");

        if POSSalesHeader.FindSet() then
            repeat
                POSSalesLines.Reset;
                POSSalesLines.SetRange("Document Type", POSSalesHeader."Document Type");
                POSSalesLines.SetRange("Document No.", POSSalesHeader."No.");
                POSSalesLines.DeleteAll();
                POSSalesHeader.Delete();
            until POSSalesHeader.Next() = 0;
    end;

    local procedure TransferPayments()
    var
        POSPaymntRec: Record POSPaymntRecvd;
        POSPymntTranf: Record POSPaymntRecvdTransf;
        PaymtJnl: Record "Gen. Journal Line";
        RecLoc: Record POSLocationPostJnls;
        LineNo: Integer;
    begin
        POSPaymntRec.Reset();
        if POSPaymntRec.FindFirst() then begin
            RecLoc.SetRange(Location, POSPaymntRec.Location);
            PaymtJnl.SetRange("Journal Template Name", RecLoc."Payment JTN to Use");
            PaymtJnl.SetRange("Journal Batch Name", RecLoc."Payment JBN to Use");
            if PaymtJnl.FindLast() then
                LineNo += 10000;
            repeat
                PaymtJnl."Journal Template Name" := POSPaymntRec."Journal Template Name";
                PaymtJnl."Journal Batch Name" := POSPaymntRec."Journal Batch Name";
                PaymtJnl."Line No." := LineNo;
                PaymtJnl."Document Type" := PaymtJnl."Document Type"::Payment;
                PaymtJnl."Document No." := POSPaymntRec."Document No.";
                PaymtJnl."Account Type" := POSPaymntRec."Account Type";
                PaymtJnl."Account No." := POSPaymntRec."Account No.";
                PaymtJnl."Posting Date" := POSPaymntRec."Posting Date";
                PaymtJnl.Validate(Amount, POSPaymntRec.Amount * -1);
                PaymtJnl."Bal. Account Type" := POSPaymntRec."Bal. Account Type";
                PaymtJnl."Bal. Account No." := POSPaymntRec."Bal. Account No.";
                PaymtJnl."External Document No." := POSPaymntRec."External Document No.";
                PaymtJnl.Description := POSPaymntRec.Description;
                PaymtJnl."Due Date" := POSPaymntRec."Due Date";
                PaymtJnl."Reason Code" := POSPaymntRec."Reason Code";
                PaymtJnl."Source Code" := 'DIACOBROS';
                PaymtJnl.Insert(true);
                LineNo += 10000;
                POSPymntTranf.TransferFields(POSPaymntRec);
                POSPymntTranf.Insert(true);
                POSPaymntRec.Processed := true;
                POSPaymntRec.Modify();
                until POSPaymntRec.Next() = 0;
                DeletePayments;
        end
    end;

        local procedure DeletePayments()
    var
        POSPaymntRec: Record POSPaymntRecvd;
    begin
        POSPaymntRec.Reset();
        POSPaymntRec.SetRange(Processed, true);
        if POSPaymntRec.FindSet() then
           POSPaymntRec.DeleteAll();
    end;
}
