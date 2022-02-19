pageextension 50000 "BOD Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field(Status; Rec."BOD Status")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the Status of Customer Document.';
            }
        }
    }
}
