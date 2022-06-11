permissionset 50001 "SP Connector"
{
    Assignable = true;
    Caption = 'Sharepoint Connector', MaxLength = 30;
    Permissions =
        table "BOD Sharepoint Setup" = X,
        tabledata "BOD Sharepoint Setup" = RMID,
        page "BOD Sharepoint Setup" = X;
}
