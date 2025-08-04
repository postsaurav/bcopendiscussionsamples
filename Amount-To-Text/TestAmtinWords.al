page 50000 "Test Amount in Words"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Enter Amount';

                }
                field(Lanaguage; Lanaguage)
                {
                    ApplicationArea = All;
                    TableRelation = "Windows Language";
                    Caption = 'Choose Language';
                }
            }
            group(Results)
            {
                field(AmountinWords; AmountinWords[1] + AmountinWords[2])
                {
                    ApplicationArea = All;
                    Editable = False;
                    MultiLine = true;
                    Caption = 'Amount in Words';
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(ConvertToWords)
            {
                ApplicationArea = All;
                Promoted = true;
                Image = UnitConversions;
                trigger OnAction()
                begin
                    If Amount > 0 then
                        ChkTransMgt.FormatNoText(AmountinWords, Amount, Lanaguage, '');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Lanaguage := 1033;
    end;

    var
        Amount: Decimal;
        Lanaguage: Integer;
        AmountinWords: array[2] of Text[80];
        ChkTransMgt: Report "Check Translation Management";
}