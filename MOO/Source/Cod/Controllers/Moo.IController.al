interface "Moo.IController"
{
    procedure Create(mooFunction: integer; object: Text): Text;
    procedure Retrieve(mooFunction: integer; object: Text): Text;
    procedure Update(mooFunction: integer; object: Text): Text;
    procedure Delete(mooFunction: integer; object: Text): Text;
}
