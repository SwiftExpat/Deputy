unit frmDeputyInstanceManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, SE.ProcMgrUtils;

type
  TDeputyInstanceManager = class(TForm)
    Label1: TLabel;
    btnCloseOriginal: TButton;
    btnCloseInstance: TButton;
    btnHideMessage: TButton;
    memoLog: TMemo;
    procedure btnHideMessageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseInstanceClick(Sender: TObject);
    procedure btnCloseOriginalClick(Sender: TObject);
  strict private
    FProcInfo, FDupInfo: TSEProcessInfo;
    FProcMgr: TSEProcessManager;
  private
    procedure LogMsg(AMessage: string);
    procedure LogInfo;
  public
    procedure CheckSecondInstance;
  end;

var
  DeputyInstanceManager: TDeputyInstanceManager;

implementation

{$R *.dfm}

procedure TDeputyInstanceManager.btnCloseInstanceClick(Sender: TObject);
begin
  Application.Terminate; // gracefully exit this instance of the IDE
end;

procedure TDeputyInstanceManager.btnCloseOriginalClick(Sender: TObject);
begin
  LogMsg('Terminating proc id :' + FDupInfo.ProcID.ToString);
  FProcMgr.TerminateProcessByID(FDupInfo.ProcID);
end;

procedure TDeputyInstanceManager.btnHideMessageClick(Sender: TObject);
begin
  self.Hide;
end;

procedure TDeputyInstanceManager.CheckSecondInstance;
begin
  try
    FProcInfo.ProcID := GetCurrentProcessID;
    if FProcMgr.ProcInfo(FProcInfo) then
    begin
      LogInfo;
      self.Show;
      if FProcMgr.ProcessIsSecondInstance(FProcInfo, FDupInfo) then
      begin
        LogMsg('Second instance');
      end
      else
        LogMsg('First instance');
    end
    else
      LogMsg('Could not get proc info');
  except
    on E: Exception do
      LogMsg('Exception:' + E.Message);
  end;
end;

procedure TDeputyInstanceManager.FormCreate(Sender: TObject);
begin
  FProcMgr := TSEProcessManager.Create;
  FProcInfo := TSEProcessInfo.Create;
  FDupInfo := TSEProcessInfo.Create;
end;

procedure TDeputyInstanceManager.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
  FProcInfo.Free;
  FDupInfo.Free;
end;

procedure TDeputyInstanceManager.LogInfo;
begin
  LogMsg('ProcID = ' + FProcInfo.ProcID.ToString);
  LogMsg('ParentID = ' + FProcInfo.ParentProcID.ToString);
  LogMsg('ProcPath = ' + FProcInfo.ImagePath);
  LogMsg('Command Line' + FProcInfo.CommandLine);
end;

procedure TDeputyInstanceManager.LogMsg(AMessage: string);
begin
  memoLog.Lines.Add(AMessage);
end;

end.
