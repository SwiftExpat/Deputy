unit frmDeputyProcMgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SE.ProcMgrUtils,
  Vcl.CategoryButtons, Vcl.ExtCtrls;

type
  EDeputyProcMgrCreate = class(Exception);

  TDeputyProcMgr = class(TForm)
    memoLeak: TMemo;
    StatusBar1: TStatusBar;
    lbMgrParams: TListBox;
    lbMgrStatus: TListBox;
    pcWorkarea: TPageControl;
    tsParameters: TTabSheet;
    tsStatus: TTabSheet;
    FlowPanel1: TFlowPanel;
    btnAbortManager: TButton;
    btnForceTerminate: TButton;
    tmrCleanupBegin: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAbortManagerClick(Sender: TObject);
    procedure btnForceTerminateClick(Sender: TObject);
    procedure tmrCleanupBeginTimer(Sender: TObject);
  strict private
    procedure ClearLog;
    procedure ClearMemLeak;
  private
    FProcMgr: TSEProcessManager;
    FProcCleanup: TSEProcessCleanup;
    FProcMgrInfo: TSEProcessManagerEnvInfo;
    procedure LogMsg(AMessage: string);
    procedure LeakCopied(AMessage: string);
    procedure WaitPoll(APollCount: integer);
  public
    procedure CleanProcess(const AProcName: string; const AProcDirectory: string;
      const AStopCommand: TSEProcessStopCommand);
    procedure LoadProcessCleanup;
  end;

  TDeputyProcMgrFactory = class
  public
    class function DeputyProcMgr: TDeputyProcMgr;
  end;

implementation

{$R *.dfm}
{ TDeputyProcMgr }

procedure TDeputyProcMgr.LoadProcessCleanup;
begin
  ClearMemLeak;
  ClearLog;
  lbMgrParams.Clear;
  lbMgrParams.Items.Add('Process Name');
  lbMgrParams.Items.Add(FProcCleanup.ProcessName);

  lbMgrParams.Items.Add('Timeout');
  lbMgrParams.AddItem(FProcCleanup.Timeout.ToString, nil);
  lbMgrParams.Items.Add('Clean Proc Action');
  if FProcCleanup.StopCommand = TSEProcessStopCommand.tseProcStopKill then
    lbMgrParams.Items.Add('Terminate')
  else
    lbMgrParams.Items.Add('Close Window');
  lbMgrParams.Items.Add('MemLeak Action');
  if FProcCleanup.CloseMemLeak then
    lbMgrParams.Items.Add('Close Leak Window')
  else
    lbMgrParams.Items.Add('Leak Window Shown');
  tmrCleanupBegin.Enabled := true;
end;

procedure TDeputyProcMgr.btnAbortManagerClick(Sender: TObject);
begin
  FProcMgr.StopManager;
end;

procedure TDeputyProcMgr.btnForceTerminateClick(Sender: TObject);
begin
  FProcMgr.StopManager;
end;

procedure TDeputyProcMgr.CleanProcess(const AProcName, AProcDirectory: string;
  const AStopCommand: TSEProcessStopCommand);
begin
  FProcCleanup := TSEProcessCleanup.Create(AProcName, AProcDirectory, AStopCommand);
  LoadProcessCleanup;
end;

procedure TDeputyProcMgr.ClearLog;
begin
  lbMgrStatus.Clear;
end;

procedure TDeputyProcMgr.ClearMemLeak;
begin
  memoLeak.Lines.Clear;
end;

procedure TDeputyProcMgr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FProcMgr.StopManager;
end;

procedure TDeputyProcMgr.FormCreate(Sender: TObject);
begin
  FProcMgrInfo := TSEProcessManagerEnvInfo.Create;
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
  FProcMgr.OnLeakCopied := LeakCopied;
  FProcMgr.OnWaitPoll := WaitPoll;
end;

procedure TDeputyProcMgr.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
  FProcMgrInfo.Free;
  FProcCleanup.Free;
end;

procedure TDeputyProcMgr.LeakCopied(AMessage: string);
begin
  ClearMemLeak;
  PostMessage(memoLeak.Handle, WM_Paste, 0, 0);
  // copy leak to hist
end;

procedure TDeputyProcMgr.LogMsg(AMessage: string);
begin
  lbMgrStatus.Items.Add(AMessage);
end;

procedure TDeputyProcMgr.tmrCleanupBeginTimer(Sender: TObject);
begin
  tmrCleanupBegin.Enabled := false;
  FProcMgr.AssignMgrInfo(FProcMgrInfo);
  FProcMgr.AssignProcCleanup(FProcCleanup);
  FProcMgr.ProcessCleanup;    //start the thread
end;

procedure TDeputyProcMgr.WaitPoll(APollCount: integer);
begin
  LogMsg(APollCount.ToString);

end;

{ TDeputyProcMgrFactory }

class function TDeputyProcMgrFactory.DeputyProcMgr: TDeputyProcMgr;
var
  i: integer;
begin
  for i := 0 to Screen.FormCount - 1 do // itterate the screens
    if Screen.Forms[i].ClassType = TDeputyProcMgr then
    begin
      result := TDeputyProcMgr(Screen.Forms[i]);
      if Screen.Forms[i].WindowState = TWindowState.wsMinimized then
        Screen.Forms[i].WindowState := TWindowState.wsNormal;
      exit;
    end;
  result := nil;
  try
    result := TDeputyProcMgr.Create(Application);
  except // handle anything that does not let our form show up
    on E: Exception do
    begin
      if Assigned(result) then
        result.Free;
      raise EDeputyProcMgrCreate.Create('Create failed Deputy Proc Manager form');
    end;
  end;
end;

end.
