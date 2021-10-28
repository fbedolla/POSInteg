/// <summary>
/// EnumPOSErrorOperType (ID 62001).
/// </summary>
enum 62001 POSErrorOperType
{
    Extensible = true;

    value(0; "Process Transaction")
    {
        Caption = 'Process Transaction';
    }
    value(1; "Process Payment")
    {
        Caption = 'Process Payment';
    }
    value(2; "Post Document")
    {
        Caption = 'Post Document';
    }
    value(3; "Post Jnl. Record")
    {
        Caption = 'Post Jnl. Record';
    }

}
