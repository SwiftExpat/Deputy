unit frmShowMessageU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Generics.Collections, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

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

  TLeakLoopTester = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnLoop: TButton;
    memTable: TFDMemTable;
    memTableLeakName: TStringField;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnLoopClick(Sender: TObject);
  private
    { Private declarations }
    FLeakRoot: TLeakParent;
  public
    { Public declarations }
  end;

var
  LeakLoopTester: TLeakLoopTester;

implementation

{$R *.dfm}

procedure TLeakLoopTester.btnLoopClick(Sender: TObject);
var
  l: TLeaker;
begin
  memTable.Open;
  memTable.Append;
  memTable.FieldbyName('LeakName').AsString := 'leaky';
  memTable.Post;
  memTable.First;
  while not memTable.Eof do
  begin
    l := TLeaker.Create;
    l.leakstring := memTable.FieldbyName('LeakName').AsString;
    Memo1.Lines.Add(l.leakstring);
    //memTable.Next;
  end;
end;

procedure TLeakLoopTester.Button1Click(Sender: TObject);
var
  lk: TLeaker;
begin
  lk := TLeaker.Create;
  lk.leakstring := 'long string';
  //ShowMessage('This is a body message');
end;

procedure TLeakLoopTester.Button2Click(Sender: TObject);
begin
  FLeakRoot := TLeakParent.Create
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

end.
