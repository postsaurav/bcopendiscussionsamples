page 50001 "BOD Sharepoint Setup"
{
    Caption = 'Sharepoint Setup';
    PageType = Card;
    SourceTable = "BOD Sharepoint Setup";
    ApplicationArea = all;
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            group(AppSetup)
            {
                Caption = 'Azure App Setup';
                field("Application ID"; Rec."Application ID")
                {
                    ToolTip = 'Specifies the value of the Azure Application (client) ID.';
                    ApplicationArea = All;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ToolTip = 'Specifies the value of the Azure Client Secret field.';
                    ApplicationArea = All;
                }
                field("OAuth Redirect Url"; Rec."OAuth Redirect Url")
                {
                    ToolTip = 'Specifies the value of the Azure OAuth Redirect Url field.';
                    ApplicationArea = All;
                }
                field("Redirect URL"; Rec."Redirect URL")
                {
                    ToolTip = 'Specifies the value of the Azure Redirect URL field.';
                    ApplicationArea = All;
                }
            }
            group(Sharepoint)
            {
                Caption = 'Sharepoint Setup';
                field("Site Name"; Rec."Site Name")
                {
                    ToolTip = 'Specifies the value of the Site Name field.';
                    ApplicationArea = All;
                }
                field("Document Libarary Name"; Rec."Document Libarary Name")
                {
                    ToolTip = 'Specifies the value of the Document Libarary Name field.';
                    ApplicationArea = All;
                }
                field("Document Folder"; Rec."Document Folder")
                {
                    ToolTip = 'Specifies the value of the Document Folder field.';
                    ApplicationArea = All;
                }
            }
            group(SharepointIds)
            {
                Caption = 'Sharepoint ID';
                field("Site id"; Rec."Site id")
                {
                    ToolTip = 'Specifies the value of the Site Name field.';
                    ApplicationArea = All;
                }
                field("Document Libarary id"; Rec."Document Libarary id")
                {
                    ToolTip = 'Specifies the value of the Document Libarary id field.';
                    ApplicationArea = All;
                }
                field("Document Folder id"; Rec."Document Folder id")
                {
                    ToolTip = 'Specifies the value of the Document id field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Consent)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Grant Consent';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                ToolTip = 'Grant consent for this application to access data from Business Central.';
                trigger OnAction()
                begin
                    Rec.GrantConsent();
                end;
            }
        }
    }

}
