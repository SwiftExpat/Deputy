unit frmIdeEmulator;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmIdeEmulate = class(TForm)
    Memo1: TMemo;
    btnCheckRunning: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCheckRunningClick(Sender: TObject);
  private
    FExeName:string;
    function CheckIdeRunning: boolean;
    procedure LogMsg(AMessage: string);
    function ExeName(ACmdLine:string):string;
  public
    { Public declarations }
  end;

var
  frmIdeEmulate: TfrmIdeEmulate;

implementation

{$R *.dfm}

uses SE.ProcMgrUtils;

procedure TfrmIdeEmulate.btnCheckRunningClick(Sender: TObject);
begin
    if CheckIdeRunning then
     LogMsg('IDE running');
end;

function TfrmIdeEmulate.CheckIdeRunning: boolean;
var procMgr : TSEProcessManager;
fn, dn:string;
begin
  procMgr := TSEProcessManager.Create;
  FExeName := ExeName(cmdLine);
  LogMsg('Parsed ExeName = '+ FExeName);
  result := procMgr.ProcFileExists(FExeName, fn, dn);
end;
/// <summary>
///   Parses exe name from Cmdline sys
/// </summary>
/// <remarks>
///   "C:\Repos\Github\Deputy\DevTools\IDEEmulator\Win32\Debug\idebds.exe" -r keyname -user username -pass pwd
/// </remarks>
function TfrmIdeEmulate.ExeName(ACmdLine:string): string;
var q1:integer;
begin
q1:= ACmdLine.IndexOf('"');
result := ACmdLine.Substring((q1+1), ACmdLine.IndexOf('"',(q1+1))-1);
end;

procedure TfrmIdeEmulate.FormCreate(Sender: TObject);
var
  I: integer;
begin
  Memo1.Lines.Clear;
  LogMsg('started with cmdLine: ' + cmdLine);
  for I := 1 to ParamCount do
    LogMsg(ParamStr(I));
end;

procedure TfrmIdeEmulate.LogMsg(AMessage: string);
begin
  Memo1.Lines.Add(AMessage);
end;

end.
