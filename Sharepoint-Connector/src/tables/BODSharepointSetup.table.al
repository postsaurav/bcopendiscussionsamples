table 50001 "BOD Sharepoint Setup"
{
    Caption = 'Sharepoint Setup';
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Application ID"; Guid)
        {
            Caption = 'Application ID';
            DataClassification = CustomerContent;
        }
        field(3; "Client Secret"; Text[1024])
        {
            Caption = 'Client Secret';
            ExtendedDatatype = Masked;
            DataClassification = CustomerContent;
        }
        field(4; "OAuth Redirect Url"; Text[1024])
        {
            Caption = 'OAuth Redirect Url';
            DataClassification = CustomerContent;
        }
        field(5; "Redirect URL"; Text[1024])
        {
            Caption = 'Redirect URL';
            DataClassification = CustomerContent;
        }
        field(10; "Site Name"; Text[1024])
        {
            Caption = 'Site Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SharepointMgmt: Codeunit "BOD Sharepoint Mgmt.";
                SiteBaseURL: Label 'https://graph.microsoft.com/v1.0/sites?search=%1', Comment = '%1 Site Name';
            begin
                if Rec."Site Name" = '' then begin
                    Clear("Site id");
                    Validate("Document Libarary Name", '');
                    Validate("Document Folder", '');
                end else
                    SharepointMgmt.GetSharepointID('https://graph.microsoft.com/v1.0/sites/root', Rec."Site id");
            end;
        }
        field(11; "Document Libarary Name"; Text[1024])
        {
            Caption = 'Document Libarary Name';
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                SharepointMgmt: Codeunit "BOD Sharepoint Mgmt.";
                DriveBaseURL: Label 'https://graph.microsoft.com/v1.0/sites/%1/drives', Comment = '%1 Site Name';
            begin
                if Rec."Document Libarary Name" = '' then begin
                    Clear("Document Libarary id");
                    Validate("Document Folder", '');
                end else
                    SharepointMgmt.GetDriveID(StrSubstNo(DriveBaseURL, Rec."Site id"), Rec."Document Libarary Name", Rec."Document Libarary id");
            end;
        }
        field(12; "Document Folder"; Text[1204])
        {
            Caption = 'Document Folder';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Document Folder" = '' then
                    Clear("Document Folder id");
            end;
        }
        field(20; "Site id"; Text[1024])
        {
            Caption = 'Site Id';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Document Libarary id"; Text[1024])
        {
            Caption = 'Document Libarary id';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "Document Folder id"; Text[1204])
        {
            Caption = 'Document Folder id';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GrantConsent()
    var

        OAuth2: Codeunit OAuth2;
        Success: Boolean;
        ErrorMsgTxt: Text;
        CommonOAuthAuthorityUrlLbl: Label 'https://login.microsoftonline.com/common/adminconsent', Locked = true;
        ConsentFailedErr: Label 'Failed to give consent.';
        ConsentSuccessTxt: Label 'Consent was given successfully.';
    begin
        OAuth2.RequestClientCredentialsAdminPermissions(GraphMgtGeneralTools.StripBrackets(Format("Application ID")), CommonOAuthAuthorityUrlLbl, '', Success, ErrorMsgTxt);
        if not Success then
            if ErrorMsgTxt <> '' then
                Error(ErrorMsgTxt)
            else
                Error(ConsentFailedErr);
        Message(ConsentSuccessTxt);
    end;

    procedure GetAccessToken() AccessToken: Text
    var
        OAuth2: Codeunit OAuth2;
        AuthError: Text;
        Scopes: List of [Text];
        PromptInteraction: Enum "Prompt Interaction";
    begin
        Scopes.Add('https://graph.microsoft.com/.default');
        Rec.Get();
        OAuth2.AcquireAuthorizationCodeTokenFromCache(GraphMgtGeneralTools.StripBrackets(Format("Application ID")),
                                                      "Client Secret", "Redirect URL", "OAuth Redirect Url", Scopes, AccessToken);

        if AccessToken <> '' then
            exit;

        OAuth2.AcquireTokenByAuthorizationCode(GraphMgtGeneralTools.StripBrackets(Format("Application ID")),
                                              "Client Secret", "OAuth Redirect Url", "Redirect URL", Scopes, PromptInteraction::"Select Account",
                                              AccessToken, AuthError);

        if AccessToken = '' then
            Error(AuthError);
    end;

    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
}
