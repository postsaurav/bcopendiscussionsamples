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

    trigger OnAfterModify()
    var
        ModifyMsg: Label 'Record %1 has been modified and Status has been set to Open', Comment = '%1 = Customer No';
    begin
        if "BOD Status" = "BOD Status"::Released then begin
            "BOD Status" := "BOD Status"::Open;
            Modify();
            Message(ModifyMsg, "No.");
        end;
    end;
}