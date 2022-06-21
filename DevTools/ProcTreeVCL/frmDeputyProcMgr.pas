unit frmDeputyProcMgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SE.ProcMgrUtils,
  Vcl.CategoryButtons, Vcl.ExtCtrls, System.Threading, Generics.Collections, System.Diagnostics;

type
  EDeputyProcMgrCreate = class(Exception);

  TDeputyProcMgr = class(TForm)
    memoLeak: TMemo;
    sbMain: TStatusBar;
    lbMgrParams: TListBox;
    lbMgrStatus: TListBox;
    pcWorkarea: TPageControl;
    tsParameters: TTabSheet;
    tsStatus: TTabSheet;
    FlowPanel1: TFlowPanel;
    btnAbortCleanup: TButton;
    btnForceTerminate: TButton;
    tmrCleanupStatus: TTimer;
    gpCleanStatus: TGridPanel;
    lblLCHdr: TLabel;
    lblLoopCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAbortCleanupClick(Sender: TObject);
    procedure btnForceTerminateClick(Sender: TObject);
    procedure tmrCleanupStatusTimer(Sender: TObject);
  strict private
    FProcMREW: TMultiReadExclusiveWriteSynchronizer;
    FPProcCleanup: TSEProcessCleanup;
    FPProcMgrInfo: TSEProcessManagerEnvInfo;
    FCleanTask: ITask;
    FCleanups: TObjectList<TSEProcessCleanup>;
    FProcMgr: TSEProcessManager;
    FStopWatch: TStopWatch;
    function ProcCleanupGet: TSEProcessCleanup;
    procedure ProcCleanupSet(const Value: TSEProcessCleanup);
    function ProcMgrInfoGet: TSEProcessManagerEnvInfo;
    procedure ProcMgrInfoSet(const Value: TSEProcessManagerEnvInfo);
    procedure ClearLog;
    procedure ClearMemLeak;
    function AddCleanup(const AProcName: string; const AProcDirectory: string;
      const AStopCommand: TSEProcessStopCommand): TSEProcessCleanup;
    procedure StatusBarUpdateMessage(AMsg: string);
    procedure UpdateTaskStatus;
    procedure StartCleanupStatus;
  private
    procedure LogMsg(AMessage: string);
    procedure LeakCopied(AMessage: string);
    procedure WaitPoll(APollCount: integer);
    property ProcCleanup: TSEProcessCleanup read ProcCleanupGet write ProcCleanupSet;
    property ProcMgrInfo: TSEProcessManagerEnvInfo read ProcMgrInfoGet write ProcMgrInfoSet;
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
  lbMgrParams.Items.Add(ProcCleanup.ProcessName);

  lbMgrParams.Items.Add('Timeout');
  lbMgrParams.AddItem(ProcCleanup.Timeout.ToString, nil);
  lbMgrParams.Items.Add('Clean Proc Action');
  if ProcCleanup.StopCommand = TSEProcessStopCommand.tseProcStopKill then
    lbMgrParams.Items.Add('Terminate')
  else
    lbMgrParams.Items.Add('Close Window');
  lbMgrParams.Items.Add('MemLeak Action');
  if ProcCleanup.CloseMemLeak then
    lbMgrParams.Items.Add('Close Leak Window')
  else
    lbMgrParams.Items.Add('Leak Window Shown');

end;

function TDeputyProcMgr.AddCleanup(const AProcName, AProcDirectory: string; const AStopCommand: TSEProcessStopCommand)
  : TSEProcessCleanup;
begin
  result := TSEProcessCleanup.Create(AProcName, AProcDirectory, AStopCommand);
  FCleanups.Add(result);
end;

procedure TDeputyProcMgr.btnAbortCleanupClick(Sender: TObject);
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
  ProcCleanup := AddCleanup(AProcName, AProcDirectory, AStopCommand);
  LoadProcessCleanup;
  FCleanTask := TTask.Create(
    procedure
    var
      ExceptionPtr: Pointer;
      exStr: string;
    begin
      try
        FProcMgr.AssignMgrInfo(ProcMgrInfo);
        FProcMgr.AssignProcCleanup(ProcCleanup);
        FProcMgr.ProcessCleanup;
      except
        begin
          ExceptionPtr := AcquireExceptionObject;
          exStr := TObject(ExceptionPtr).ToString;
          ReleaseExceptionObject;
          TThread.Queue(TThread.CurrentThread,
            procedure
            begin
              LogMsg(exStr);
            end);
        end;
      end;
    end);
  StartCleanupStatus;
  FCleanTask.Start;
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
  FProcMREW := TMultiReadExclusiveWriteSynchronizer.Create;
  FCleanups := TObjectList<TSEProcessCleanup>.Create(true);
  ProcMgrInfo := TSEProcessManagerEnvInfo.Create;
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
  FProcMgr.OnLeakCopied := LeakCopied;
  FProcMgr.OnWaitPoll := WaitPoll;
end;

procedure TDeputyProcMgr.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
  FProcMREW.Free;
  FPProcMgrInfo.Free;
  FCleanups.Free;
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

function TDeputyProcMgr.ProcCleanupGet: TSEProcessCleanup;
begin
  FProcMREW.BeginRead;
  result := FPProcCleanup;
  FProcMREW.EndRead;
end;

procedure TDeputyProcMgr.ProcCleanupSet(const Value: TSEProcessCleanup);
begin
  FProcMREW.BeginWrite;
  FPProcCleanup := Value;
  FProcMREW.EndWrite;
end;

function TDeputyProcMgr.ProcMgrInfoGet: TSEProcessManagerEnvInfo;
begin
  FProcMREW.BeginRead;
  result := FPProcMgrInfo;
  FProcMREW.EndRead;
end;

procedure TDeputyProcMgr.ProcMgrInfoSet(const Value: TSEProcessManagerEnvInfo);
begin
  FProcMREW.BeginWrite;
  FPProcMgrInfo := Value;
  FProcMREW.EndWrite;
end;

procedure TDeputyProcMgr.StartCleanupStatus;
begin
  UpdateTaskStatus;
  WaitPoll(0);
  FStopWatch := TStopWatch.StartNew;
  tmrCleanupStatus.Enabled := true;
  gpCleanStatus.Visible := true;
end;

procedure TDeputyProcMgr.StatusBarUpdateMessage(AMsg: string);
begin
  sbMain.Panels[0].Text := AMsg;
end;

procedure TDeputyProcMgr.tmrCleanupStatusTimer(Sender: TObject);
begin
  UpdateTaskStatus;
  if FCleanTask.Status = TTaskStatus.Completed then
  begin
    tmrCleanupStatus.Enabled := false;
    gpCleanStatus.Visible := false;
    FStopWatch.Stop;
  end;
end;

procedure TDeputyProcMgr.UpdateTaskStatus;
begin
  case FCleanTask.Status of
    TTaskStatus.Created:
      StatusBarUpdateMessage('Created');
    TTaskStatus.WaitingToRun:
      StatusBarUpdateMessage('Waiting to Run');
    TTaskStatus.Running:
      StatusBarUpdateMessage('Running');
    TTaskStatus.Completed:
      StatusBarUpdateMessage('Completed');
    TTaskStatus.WaitingForChildren:
      StatusBarUpdateMessage('Waiting for Children');
    TTaskStatus.Canceled:
      StatusBarUpdateMessage('Canceled');
    TTaskStatus.Exception:
      StatusBarUpdateMessage('Exception');
  end;
end;

procedure TDeputyProcMgr.WaitPoll(APollCount: integer);
begin
  LblLoopCount.Caption := APollCount.ToString;
end;

{ TDeputyProcMgrFactory }

class function TDeputyProcMgrFactory.DeputyProcMgr: TDeputyProcMgr;
var
  I: integer;
begin
  for I := 0 to Screen.FormCount - 1 do // itterate the screens
    if Screen.Forms[I].ClassType = TDeputyProcMgr then
    begin
      result := TDeputyProcMgr(Screen.Forms[I]);
      if Screen.Forms[I].WindowState = TWindowState.wsMinimized then
        Screen.Forms[I].WindowState := TWindowState.wsNormal;
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
