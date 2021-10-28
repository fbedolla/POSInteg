/// <summary>
/// PagePOSErrorLog (ID 62004).
/// </summary>
page 62004 POSErrorLog
{

    ApplicationArea = All;
    Caption = 'POSErrorLog';
    PageType = List;
    SourceTable = POSIntegErrorLog;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Operation Type"; Rec."Operation Type")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Entry Date/Time"; Rec."Entry Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Record Identifier"; Rec."Record Identifier")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
