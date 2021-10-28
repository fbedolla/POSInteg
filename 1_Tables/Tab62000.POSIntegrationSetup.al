/// <summary>
/// Table POS Integration Setup (ID 62000).
/// </summary>
table 62000 "POS Integration Setup"
{
    Caption = 'POS Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Automatic Sales Procesor"; Boolean)
        {
            Caption = 'Automatic Sales Procesor';
            DataClassification = CustomerContent;
        }
        field(21; "Sales Doc. Reason Code"; Code[20])
        {
            Caption = 'Sales Doc. Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(22; "Delete Procesed Line"; Boolean)
        {
            Caption = 'Delete Procesed Line';
            DataClassification = CustomerContent;
        }
        field(30; "Payment Template Name"; Code[10])
        {
            Caption = 'Payment Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template" where(Type = const("Cash Receipts"));
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}
