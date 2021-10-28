/// <summary>
/// EnumPOSActType (ID 62002).
/// </summary>
enum 62002 POSActType
{
    Extensible = true;

    value(0; CREATESALESDOCUMENTS)
    {
        Caption = 'CREATESALESDOCUMENTS';
    }
    value(1; POSTDOCUMENTS)
    {
        Caption = 'POSTDOCUMENTS';
    }
    value(2; CREATEPAYMENTJNLRECS)
    {
        Caption = 'CREATEPAYMENTJNLRECS';
    }
    value(3; POSTPAYMENTS)
    {
        Caption = 'POSTPAYMENTS';
    }

}
