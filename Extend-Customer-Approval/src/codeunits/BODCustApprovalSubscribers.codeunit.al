codeunit 50000 "BOD Cust Approval Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeCheckBlockedCust', '', false, false)]
    local procedure CheckCustomerStatus(Customer: Record Customer)
    begin
        Customer.TestField("BOD Status", Customer."BOD Status"::Released);
    end;
}