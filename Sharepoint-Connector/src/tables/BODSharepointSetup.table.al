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
            begin
                if Rec."Site Name" = '' then begin
                    Clear("Site id");
                    Validate("Document Libarary Name", '');
                    Validate("Document Folder", '');
                end;
            end;
        }
        field(11; "Document Libarary Name"; Text[1024])
        {
            Caption = 'Document Libarary Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Document Libarary Name" = '' then begin
                    Clear("Document Libarary id");
                    Validate("Document Folder", '');
                end;
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
}
