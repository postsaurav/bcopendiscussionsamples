page 50000 "BOD Doc. Attachment Factbox"
{
    Caption = 'BOD Doc. Attachment Factbox';
    PageType = CardPart;
    SourceTable = "Document Attachment";

    layout
    {
        area(content)
        {
            group(Control2)
            {
                ShowCaption = false;
                field(Documents; NumberOfRecords)
                {
                    ApplicationArea = All;
                    Caption = 'Documents';
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the number of attachments.';

                    trigger OnDrillDown()
                    var
                        BankAcc: Record "Bank Account";
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                        AttachmentType: Boolean;

                    begin
                        AttachmentType := false;
                        case Rec."Table ID" of
                            0:
                                exit;
                            DATABASE::"Bank Account":
                                begin
                                    RecRef.Open(DATABASE::"Bank Account");
                                    if BankAcc.Get(Rec."No.") then
                                        RecRef.GetTable(BankAcc);
                                end;
                            else
                                OnBeforeDrillDown(Rec, RecRef);
                        end;

                        DocumentAttachmentDetails.OpenForRecRef2(RecRef);
                        DocumentAttachmentDetails.RunModal;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
    end;

    trigger OnAfterGetCurrRecord()
    var
        currentFilterGroup: Integer;
    begin
        currentFilterGroup := Rec.FilterGroup;
        Rec.FilterGroup := 4;

        NumberOfRecords := 0;
        if Rec.GetFilters() <> '' then
            NumberOfRecords := Rec.Count;
        Rec.FilterGroup := currentFilterGroup;
    end;

    var
        NumberOfRecords: Integer;
}

