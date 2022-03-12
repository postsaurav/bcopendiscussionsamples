codeunit 50001 "BOD Attachment Management"
{
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeSaveAttachment', '', false, false)]
    procedure BeforeSaveAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; FileName: Text; var TempBlob: Codeunit "Temp Blob")
    var
        BankAcc: Record "Bank Account";
    begin
        if DocumentAttachment."Table ID" = Database::"Bank Account" then begin
            Clear(RecRef);
            RecRef.Open(DATABASE::"Bank Account");
            if BankAcc.Get(DocumentAttachment."No.") then
                RecRef.GetTable(BankAcc);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertAttachment', '', false, false)]
    procedure BeforeInsertAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            Database::"Bank Account":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

}
