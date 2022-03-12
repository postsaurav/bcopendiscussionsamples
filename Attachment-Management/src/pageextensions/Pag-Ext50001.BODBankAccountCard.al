pageextension 50001 "BOD Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        addfirst(factboxes)
        {
            part("Attached Documents"; "BOD Doc. Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(270),
                              "No." = FIELD("No.");
                Visible = true;
            }
        }
    }
}
