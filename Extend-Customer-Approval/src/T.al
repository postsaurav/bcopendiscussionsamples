tableextension 50000 MyExtension extends "My Customer"
{
    fields
    {
        field(50000; MyField; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}