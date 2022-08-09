unit frmIdeEmulator;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmIdeEmulate = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmIdeEmulate: TfrmIdeEmulate;

implementation

{$R *.dfm}

procedure TfrmIdeEmulate.FormCreate(Sender: TObject);
var
  I: integer;
begin
  Memo1.Lines.Clear;
  Memo1.Lines.Add('started with cmdLine: ' + cmdLine);
  for I := 1 to ParamCount do
    Memo1.Lines.Add(ParamStr(I))
end;

end.
