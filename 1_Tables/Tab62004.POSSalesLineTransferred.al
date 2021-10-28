/// <summary>
/// TablePOSSalesLineTransf (ID 62004).
/// </summary>
table 62004 POSSalesLineTransf
{
    Caption = 'POSSalesLineTransf';
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
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(" ")) "Standard Text" else
            if (Type = const("G/L Account")) "G/L Account" else
            if (Type = const(Item)) Item else
            if (Type = const(Resource)) Resource else
            if (Type = const("Fixed Asset")) "Fixed Asset" else
            if (Type = const("Charge (Item)")) "Item Charge";
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(13; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(22; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(68; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(100; Processed; Boolean)
        {
            Caption = 'Processed';
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

}
