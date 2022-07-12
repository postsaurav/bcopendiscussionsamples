pageextension 50001 "BOD Customer List" extends "Customer List"
{
    actions
    {
        addlast(Create)
        {
            action(UploadFile)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Import File.';
                ToolTip = 'Executes the UploadFiles action to Sharepoint.';
                trigger OnAction()
                var
                    SharepointSetup: Codeunit "BOD Sharepoint Mgmt.";
                    InStream: InStream;
                    Filename: Text;
                    DownloadURL: Text[2048];
                begin
                    if not UploadIntoStream('Select File To Upload.', '', '', Filename, InStream) then
                        error('Please Select a File.');
                    DownloadURL := SharepointSetup.UploadFileToSharepoint('', FileName, InStream);
                    If DownloadURL <> '' Then
                        SharepointSetup.AddRecordLink(Rec.RecordId, Filename, DownloadURL);
                end;
            }

            action(DownloadFile)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Export File.';
                ToolTip = 'Executes the UploadFiles action to Sharepoint.';
                trigger OnAction()
                var
                    SharepointSetup: Codeunit "BOD Sharepoint Mgmt.";
                    InStream: InStream;
                    Filename: Text;
                begin
                    Filename := 'sample.txt';
                    if SharepointSetup.DownloadFileFromSharepoint('github-recovery-codes.txt', InStream) = true then
                        DownloadFromStream(InStream, '', '', '', Filename);

                end;
            }
            //DownloadFileFromSharepoint
        }
    }
}
