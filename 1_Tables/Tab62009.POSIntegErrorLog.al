/// <summary>
/// TablePOSIntegErrorLog (ID 62009).
/// </summary>
table 62009 POSIntegErrorLog
{
    Caption = 'POSIntegErrorLog';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Operation Type"; Enum POSErrorOperType)
        {
            Caption = 'Operation Type';
            DataClassification = CustomerContent;
        }
        field(10; "User ID"; Text[65])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(15; "Entry Date/Time"; DateTime)
        {
            Caption = 'Entry Date/Time';
            DataClassification = CustomerContent;
        }
        field(20; "Record Identifier"; RecordId)
        {
            Caption = 'Record Identifier';
            DataClassification = CustomerContent;
        }
        field(25; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}
