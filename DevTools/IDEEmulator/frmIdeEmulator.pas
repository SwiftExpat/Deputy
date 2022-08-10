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
    btnInstanceManager: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCheckRunningClick(Sender: TObject);
    procedure btnInstanceManagerClick(Sender: TObject);
  private
    FExeName: string;
    FBDSID: cardinal;
    function CheckIdeRunning: boolean;
    procedure LogMsg(AMessage: string);
    function ExeName(ACmdLine: string): string;
  public
    { Public declarations }
  end;

var
  frmIdeEmulate: TfrmIdeEmulate;

implementation

{$R *.dfm}

uses SE.ProcMgrUtils, frmDeputyInstanceManager;

procedure TfrmIdeEmulate.btnCheckRunningClick(Sender: TObject);
begin
  if CheckIdeRunning then
    LogMsg('IDE running');
end;

procedure TfrmIdeEmulate.btnInstanceManagerClick(Sender: TObject);
var
  im : TDeputyInstanceManager;
begin
       im := TDeputyInstanceManager.Create(self);
       im.CheckSecondInstance;
end;

function TfrmIdeEmulate.CheckIdeRunning: boolean;
var
  procMgr: TSEProcessManager;
  fn, dn: string;
  procInfo, dupInfo: TSEProcessInfo;

begin
  procMgr := TSEProcessManager.Create;
  procInfo := TSEProcessInfo.Create;
  dupInfo := TSEProcessInfo.Create;
  try
    procMgr.OnMessage := LogMsg;
    FExeName := ExeName(cmdLine);
    LogMsg('Parsed ExeName = ' + FExeName);
    result := procMgr.ProcFileExists(FExeName, fn, dn);
    if result then
      LogMsg('IDE Found');

    procInfo.ProcID := FBDSID;
    result := procMgr.procInfo(procInfo);
    if result then
    begin
      LogMsg('ProcID = ' + procInfo.ProcID.ToString);
      LogMsg('ParentID = ' + procInfo.ParentProcID.ToString);
      LogMsg('ProcPath = ' + procInfo.ImagePath);
      LogMsg('Command Line' + procInfo.CommandLine);
      if procMgr.ProcessIsSecondInstance(procInfo, dupInfo) then
      begin
       LogMsg('Second instance');
      end
      else
       LogMsg('First instance');
    end
    else
      LogMsg('Proc Not found');
  finally
    procInfo.Free;
    procMgr.Free;
  end;

end;

/// <summary>
/// Parses exe name from Cmdline sys
/// </summary>
/// <remarks>
/// "C:\Repos\Github\Deputy\DevTools\IDEEmulator\Win32\Debug\idebds.exe" -r keyname -user username -pass pwd
/// </remarks>
function TfrmIdeEmulate.ExeName(ACmdLine: string): string;
var
  q1: integer;
begin
  q1 := ACmdLine.IndexOf('"');
  result := ACmdLine.Substring((q1 + 1), ACmdLine.IndexOf('"', (q1 + 1)) - 1);
end;

procedure TfrmIdeEmulate.FormCreate(Sender: TObject);
var
  I: integer;
begin
  Memo1.Lines.Clear;
  LogMsg('started with cmdLine: ' + cmdLine);
  for I := 1 to ParamCount do
    LogMsg(ParamStr(I));
  FBDSID := GetCurrentProcessID;
  LogMsg('Procid = ' + FBDSID.ToString);
end;

procedure TfrmIdeEmulate.LogMsg(AMessage: string);
begin
  Memo1.Lines.Add(AMessage);
end;

end.
