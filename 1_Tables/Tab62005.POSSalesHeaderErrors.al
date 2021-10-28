/// <summary>
/// TablePOSSalesHeaderErrors (ID 62005).
/// </summary>
table 62005 POSSalesHeaderErrors
{
    Caption = 'POSSalesHeaderErrors';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Enum SHDocType)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(4; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(12; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code;
        }
        field(19; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(23; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms".Code;
        }
        field(28; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(100; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
        field(104; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method".Code;
        }
        field(50110; Status; enum POSIntegDocStatus)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(50111; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(50112; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
            DataClassification = CustomerContent;
        }
        field(50113; "Transaction Time"; DateTime)
        {
            Caption = 'Transaction Time';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Document Type")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        POSLine: Record POSSalesLineErrors;
    begin
        POSLine.Reset();
        POSLine.SetRange("Document Type", "Document Type");
        POSLine.SetRange("Document No.", "No.");
        POSLine.DeleteAll(true);
    end;
}
