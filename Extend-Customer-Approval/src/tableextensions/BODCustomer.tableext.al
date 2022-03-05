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
        BODCustApprovalSubscribers: Codeunit "BOD Cust Approval Subscribers";
        ModifyMsg: Label 'Record %1 has been modified and Status has been set to Open', Comment = '%1 = Customer No';
    begin
        if not BODCustApprovalSubscribers.IsCustomerApprovalWorkflowEnabled() then
            exit;

        if Rec."BOD Status" <> Rec."BOD Status"::Released then
            exit;

        Rec.Validate("BOD Status", Rec."BOD Status"::Open);
        Rec.Modify(true);
        Message(ModifyMsg, "No.");
    end;
}