/// <summary>
/// TablePOSLocationPostJnls (ID 62010).
/// </summary>
table 62010 POSLocationPostJnls
{
    Caption = 'POSLocationPostJnls';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
        }
        field(2; "Payment JTN to Use"; Code[10])
        {
            Caption = 'Payment Journal Template Name to Use';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template";
        }
        field(3; "Payment JBN to Use"; Code[10])
        {
            Caption = 'Payment Journal Batch Name to Use';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Payment JTN to Use"));
        }
    }
    keys
    {
        key(PK; Location)
        {
            Clustered = true;
        }
    }

}
