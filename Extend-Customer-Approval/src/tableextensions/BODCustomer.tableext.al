tableextension 50000 "BOD Customer" extends Customer
{
    fields
    {
        field(50000; "BOD Status"; Enum "Sales Document Status")
        {
            Caption = 'Status';
            ValuesAllowed = 0, 1, 2;
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}