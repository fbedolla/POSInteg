/// <summary>
/// EnumPOSIntegDocStatus (ID 62003).
/// </summary>
enum 62003 POSIntegDocStatus
{
    Extensible = true;

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; "Document Created")
    {
        Caption = 'Document Created';
    }
    value(2; Posted)
    {
        Caption = 'Posted';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }

}
