unit frmShowMessageU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Generics.Collections;

type

  TLeakChild = class
  strict private
    FLeakDict: TDictionary<string, string>;
  public
    constructor Create;
  end;

  TLeakParent = class
  strict private
    FLeakChild: TLeakChild;
    FLeakList: TObjectList<TLeakChild>;
  public
    constructor Create;
  end;

  TLeaker = class
    leakstring: string;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FLeakRoot: TLeakParent;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  lk: TLeaker;
begin
  lk := TLeaker.Create;
  lk.leakstring := 'long string';
  ShowMessage('This is a body message');
end;

{ TLeakParent }

constructor TLeakParent.Create;
var
  i: integer;
begin
  FLeakChild := TLeakChild.Create;
  FLeakList := TObjectList<TLeakChild>.Create;
  for i := 0 to 1000 do
    FLeakList.Add(TLeakChild.Create);
end;

{ TLeakChild }

constructor TLeakChild.Create;
const
  pfx_key = 'Key';
  pfx_val = 'Val';
var
  i: integer;
begin
  FLeakDict := TDictionary<string, string>.Create;
  for i := 0 to 5000 do
    FLeakDict.Add(pfx_key + i.ToString, pfx_val + i.ToString)

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FLeakRoot := TLeakParent.Create
end;

end.
