codeunit 50000 "BOD Cust Approval Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeCheckBlockedCust', '', false, false)]
    local procedure CheckCustomerStatus(Customer: Record Customer)
    begin
        if not IsCustomerApprovalWorkflowEnabled() then
            exit;
        Customer.TestField("BOD Status", Customer."BOD Status"::Released);
    end;

    // Check Status on Sales Document Release Validate
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnCodeOnAfterCheckCustomerCreated', '', false, false)]
    local procedure CheckCustomerSalesRelease(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
            exit;

        CheckRecordRestrictionCust(SalesHeader."Sell-to Customer No.");
        CheckRecordRestrictionCust(SalesHeader."Bill-to Customer No.");
    end;

    // Update Status on Bank Account Changes
    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnCustBankInsert(Rec: Record "Customer Bank Account"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        UpdateCustomerStatus(Rec."Customer No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnCustBankModify(Rec: Record "Customer Bank Account"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        UpdateCustomerStatus(Rec."Customer No.");
    end;


    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnCustBankDelete(Rec: Record "Customer Bank Account"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        UpdateCustomerStatus(Rec."Customer No.");
    end;


    // Update Status on Default Dim Changes
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnCustDimInsert(Rec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."Table ID" <> Database::Customer THEN
            exit;
        UpdateCustomerStatus(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnCustDimModify(Rec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."Table ID" <> Database::Customer THEN
            exit;
        UpdateCustomerStatus(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnCustDimDelete(Rec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec."Table ID" <> Database::Customer THEN
            exit;
        UpdateCustomerStatus(Rec."No.");
    end;

    //Worflow Handling
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSendCustomerForApproval', '', false, false)]
    local procedure UpdateStatusOnSendCustomerForApproval(Customer: Record Customer)
    begin
        Customer.Validate("BOD Status", Customer."BOD Status"::"Pending Approval");
        Customer.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnCancelCustomerApprovalRequest', '', false, false)]
    local procedure UpdateStatusOnCancelCustomerApprovalRequest(Customer: Record Customer)
    begin
        Customer.Validate("BOD Status", Customer."BOD Status"::Open);
        Customer.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure UpdateStatusOnApproveCustomerApprovalRequest(RecRef: RecordRef; var Handled: Boolean)
    var
        Customer: Record Customer;
        FieldRef: FieldRef;
        CustNo: Code[20];
    begin
        if RecRef.Number <> Database::Customer then
            exit;

        FieldRef := RecRef.Field(1);
        CustNo := FieldRef.Value;

        Customer.Get(CustNo);
        Customer.Validate("BOD Status", Customer."BOD Status"::Released);
        Customer.Modify();
        Handled := true;
    end;

    local procedure UpdateCustomerStatus(CustNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not IsCustomerApprovalWorkflowEnabled() then
            exit;
        Customer.Get(CustNo);
        if Customer."BOD Status" <> Customer."BOD Status"::Released then
            exit;
        Customer.Validate("BOD Status", Customer."BOD Status"::Open);
        Customer.Modify(true);
    end;

    local procedure CheckRecordRestrictionCust(CustNo: Code[20])
    var
        Customer: Record Customer;
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        if not IsCustomerApprovalWorkflowEnabled() then
            exit;
        Customer.Get(CustNo);
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(Customer);
    end;

    procedure IsCustomerApprovalWorkflowEnabled(): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkFlowEventFilter: Text;
    begin
        WorkFlowEventFilter := WorkflowEventHandling.RunWorkflowOnSendCustomerForApprovalCode() + '|' + WorkflowEventHandling.RunWorkflowOnCustomerChangedCode();
        exit(WorkflowManagement.EnabledWorkflowExist(DATABASE::Customer, WorkFlowEventFilter));
    end;
}