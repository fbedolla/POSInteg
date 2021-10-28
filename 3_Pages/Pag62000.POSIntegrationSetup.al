/// <summary>
/// Page POS Integration Setup (ID 62000).
/// </summary>
page 62000 "POS Integration Setup"
{

    Caption = 'POS Integration Setup';
    PageType = Card;
    SourceTable = "POS Integration Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Automatic Sales Procesor"; Rec."Automatic Sales Procesor")
                {
                    ApplicationArea = All;
                }
                field("Delete Procesed Line"; Rec."Delete Procesed Line")
                {
                    ApplicationArea = All;
                }
                field("Payment Template Name"; Rec."Payment Template Name")
                {
                    ApplicationArea = All;
                }
                field("Sales Doc. Reason Code"; Rec."Sales Doc. Reason Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
