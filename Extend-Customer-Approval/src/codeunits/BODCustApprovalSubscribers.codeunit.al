codeunit 50000 "BOD Cust Approval Subscribers"
{


    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeCheckBlockedCust', '', false, false)]
    local procedure CheckCustomerStatus(Customer: Record Customer)
    begin
        Customer.TestField("BOD Status", Customer."BOD Status"::Released);
    end;

    // Check Status on Sales Document Release Validate
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnCodeOnAfterCheckCustomerCreated', '', false, false)]
    local procedure CheckCustomerSalesRelease(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
            exit;

        if SalesHeader."Sell-to Customer No." = '' then
            exit;

        CheckRecordRestrictionCust(SalesHeader."Sell-to Customer No.");
        CheckRecordRestrictionCust(SalesHeader."Bill-to Customer No.");
    end;

    // Update Status on Bank Account Changes
    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnCustBankInsert(Rec: Record "Customer Bank Account")
    begin
        UpdateCustomerStatus(Rec."Customer No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnCustBankModify(Rec: Record "Customer Bank Account")
    begin
        UpdateCustomerStatus(Rec."Customer No.");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnCustBankDelete(Rec: Record "Customer Bank Account")
    begin
        UpdateCustomerStatus(Rec."Customer No.");
    end;


    // Update Status on Default Dim Changes
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnCustDimInsert(Rec: Record "Default Dimension")
    begin
        if Rec."Table ID" <> Database::Customer THEN
            exit;
        UpdateCustomerStatus(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnCustDimModify(Rec: Record "Default Dimension")
    begin
        if Rec."Table ID" <> Database::Customer THEN
            exit;
        UpdateCustomerStatus(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnCustDimDelete(Rec: Record "Default Dimension")
    begin
        if Rec."Table ID" <> Database::Customer THEN
            exit;
        UpdateCustomerStatus(Rec."No.");
    end;

    //Worflow Handling
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSendCustomerForApproval', '', false, false)]
    local procedure UpdateStatusOnSendCustomerForApproval(Customer: Record Customer)
    begin
        Customer."BOD Status" := Customer."BOD Status"::"Pending Approval";
        Customer.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnCancelCustomerApprovalRequest', '', false, false)]
    local procedure UpdateStatusOnCancelCustomerApprovalRequest(Customer: Record Customer)
    begin
        Customer."BOD Status" := Customer."BOD Status"::Open;
        Customer.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure UpdateStatusOnApproveCustomerApprovalRequest(RecRef: RecordRef; var Handled: Boolean)
    var
        Customer: Record Customer;
        FieldRef: FieldRef;
        CustNo: Code[20];
    begin
        if RecRef.Number <> 18 then
            exit;
        FieldRef := RecRef.Field(1);
        CustNo := FieldRef.Value;
        Customer.Get(CustNo);
        Customer."BOD Status" := Customer."BOD Status"::Released;
        Customer.Modify();
        Handled := true;
    end;

    local procedure UpdateCustomerStatus(CustNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustNo);
        if Customer."BOD Status" <> Customer."BOD Status"::Released then
            exit;
        Customer."BOD Status" := Customer."BOD Status"::Open;
        Customer.Modify();
    end;

    local procedure CheckRecordRestrictionCust(CustNo: Code[20])
    var
        Customer: Record Customer;
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        Customer.Get(CustNo);
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(Customer);
    end;

}