unit frmDeputyProcMgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SE.ProcMgrUtils,
  Vcl.CategoryButtons, Vcl.ExtCtrls, Generics.Collections, System.Diagnostics;

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
    Label1: TLabel;
    lblElapsedMS: TLabel;
    tsHistory: TTabSheet;
    lvHist: TListView;
    memoLeakHist: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAbortCleanupClick(Sender: TObject);
    procedure btnForceTerminateClick(Sender: TObject);
    procedure tmrCleanupStatusTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvHistInfoTip(Sender: TObject; Item: TListItem; var InfoTip: string);
    procedure lvHistSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  strict private
    FProcCleanup: TSEProcessCleanup;
    FProcMgrInfo: TSEProcessManagerEnvInfo;
    FCleanups: TObjectList<TSEProcessCleanup>;
    FHistNodes: TDictionary<TTreeNode, TSEProcessCleanup>;
    FProcMgr: TSEProcessManager;
    FStopWatch: TStopWatch;
    procedure ClearLog;
    procedure ClearMemLeak;
    function AddCleanup(const AProcName: string; const AProcDirectory: string;
      const AStopCommand: TSEProcessStopCommand): TSEProcessCleanup;
    procedure StatusBarUpdateMessage(AMsg: string);
    procedure StartCleanupStatus;
    procedure StopCleanupStatus;
  private
    procedure LogMsg(AMessage: string);
    procedure LeakCopied(AMessage: string; APID: cardinal);
    procedure WaitPoll(APollCount: integer);
    property ProcCleanup: TSEProcessCleanup read FProcCleanup write FProcCleanup;
    property ProcMgrInfo: TSEProcessManagerEnvInfo read FProcMgrInfo write FProcMgrInfo;
    procedure UpdateCleanHist(AProcCleanup: TSEProcessCleanup);
  public
    function ClearProcess(const AProcName: string; const AProcDirectory: string;
      const AStopCommand: TSEProcessStopCommand): Boolean;
    procedure LoadProcessCleanup;
    function IDECancel: Boolean;
  end;

  TDeputyProcMgrFactory = class
  public
    class function DeputyProcMgr: TDeputyProcMgr;
    class procedure ShowProcMgr;
    class procedure HideProcMgr;
  end;

implementation

{$R *.dfm}

uses DateUtils;
{ TDeputyProcMgr }

procedure TDeputyProcMgr.LoadProcessCleanup;
begin
  ClearMemLeak;
  ClearLog;
  lbMgrParams.Clear;
  lbMgrParams.Items.Add('Process Name');
  lbMgrParams.Items.Add(ProcCleanup.ProcessName);

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
var
  tli: TListItem;
begin
  result := TSEProcessCleanup.Create(AProcName, AProcDirectory, AStopCommand);
  FCleanups.Add(result);
  tli := TListItem.Create(lvHist.Items);
  lvHist.Items.AddItem(tli, 0);
  tli.Data := result;
  tli.Caption := AProcName;
  tli.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', result.StartTime));
  lvHist.Tag := tli.Index;
end;

procedure TDeputyProcMgr.btnAbortCleanupClick(Sender: TObject);
begin
  FProcMgr.StopManager;
end;

procedure TDeputyProcMgr.btnForceTerminateClick(Sender: TObject);
begin
  FProcMgr.StopManager;
end;

function TDeputyProcMgr.ClearProcess(const AProcName, AProcDirectory: string;
  const AStopCommand: TSEProcessStopCommand): Boolean;

begin
  ProcCleanup := AddCleanup(AProcName, AProcDirectory, AStopCommand);
  LoadProcessCleanup;
  FProcMgr.AssignMgrInfo(ProcMgrInfo);
  FProcMgr.AssignProcCleanup(ProcCleanup);
  self.Show;
  StartCleanupStatus; // timer to count with the stopwatch
  result := FProcMgr.ProcessCleanup;
  tmrCleanupStatus.Enabled := false; // stop the timer
  UpdateCleanHist(ProcCleanup);
  StopCleanupStatus;
  self.Hide;
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
  FCleanups := TObjectList<TSEProcessCleanup>.Create(true);
  FHistNodes := TDictionary<TTreeNode, TSEProcessCleanup>.Create;
  ProcMgrInfo := TSEProcessManagerEnvInfo.Create;
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
  FProcMgr.OnLeakCopied := LeakCopied;
  FProcMgr.OnWaitPoll := WaitPoll;
end;

procedure TDeputyProcMgr.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
  FProcMgrInfo.Free;
  FCleanups.Free;
  FHistNodes.Free;
end;

procedure TDeputyProcMgr.FormShow(Sender: TObject);
begin
  pcWorkarea.ActivePage := tsStatus;
end;

function TDeputyProcMgr.IDECancel: Boolean;
begin
  result := true;
end;

procedure TDeputyProcMgr.LeakCopied(AMessage: string; APID: cardinal);
begin
  ClearMemLeak;
  Application.ProcessMessages;
  PostMessage(memoLeak.Handle, WM_Paste, 0, 0);
  TThread.Sleep(5); // a few ms to paste
  Application.ProcessMessages;
  TThread.Sleep(5); // a few ms to paste
  if memoLeak.Lines.Text.IndexOf('leak') > -1 then
    ProcCleanup.SetLeakByPID(APID, memoLeak.Lines.Text);
end;

procedure TDeputyProcMgr.LogMsg(AMessage: string);
begin
  lbMgrStatus.Items.Add(AMessage);
  Application.ProcessMessages;
end;

procedure TDeputyProcMgr.lvHistInfoTip(Sender: TObject; Item: TListItem; var InfoTip: string);
var
  pc: TSEProcessCleanup;
begin
  if Assigned(Item.Data) then // check Item type?
    pc := TSEProcessCleanup(Item.Data)
  else
    exit;
  if pc.LeakShown then
    InfoTip := 'Leak found';
end;

procedure TDeputyProcMgr.lvHistSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  pc: TSEProcessCleanup;
begin
  if Selected and Assigned(Item.Data) then
    pc := TSEProcessCleanup(Item.Data)
  else
    exit;
  if memoLeakHist.Tag <> Item.Index then // update the hist box based on selected item index
  begin
    memoLeakHist.Clear;
    if pc.LeakShown then
      pc.LeakDetail(memoLeakHist.Lines)
    else
      memoLeakHist.Lines.Add('No Leak found ' + Item.Index.ToString);
    memoLeakHist.Tag := Item.Index;
  end;
end;

procedure TDeputyProcMgr.StartCleanupStatus;
begin
  WaitPoll(0);
  FStopWatch := TStopWatch.StartNew;
  tmrCleanupStatus.Enabled := true;
  gpCleanStatus.Visible := true;
end;

procedure TDeputyProcMgr.StatusBarUpdateMessage(AMsg: string);
begin
  sbMain.Panels[0].Text := AMsg;
end;

procedure TDeputyProcMgr.StopCleanupStatus;
begin
  tmrCleanupStatus.Enabled := false;
  gpCleanStatus.Visible := false;
  FStopWatch.Stop;
end;

procedure TDeputyProcMgr.tmrCleanupStatusTimer(Sender: TObject);
begin
  lblElapsedMS.Caption := FStopWatch.ElapsedMilliseconds.ToString;
  Application.ProcessMessages;
end;

procedure TDeputyProcMgr.UpdateCleanHist(AProcCleanup: TSEProcessCleanup);
var
  tli: TListItem;
begin
  tli := lvHist.Items[lvHist.Tag];
  tli.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', ProcCleanup.EndTime));
  tli.SubItems.Add(FStopWatch.ElapsedMilliseconds.ToString + ' ms');
  tli.SubItems.Add(boolToStr(ProcCleanup.ProcessFound, true));
  tli.SubItems.Add(boolToStr(ProcCleanup.LeakShown, true));
  memoLeakHist.Tag := -1;
end;

procedure TDeputyProcMgr.WaitPoll(APollCount: integer);
begin
  lblLoopCount.Caption := APollCount.ToString;
  Application.ProcessMessages;
end;

{ TDeputyProcMgrFactory }

// class procedure TDeputyProcMgrFactory.CleanProcess(const AProcName, AProcDirectory: string;
// const AStopCommand: TSEProcessStopCommand);
// var
// frmMgr: TDeputyProcMgr;
// begin
// frmMgr := DeputyProcMgr;
// frmMgr.Show;
// frmMgr.ClearProcess(AProcName, AProcDirectory, AStopCommand);
// end;

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

class procedure TDeputyProcMgrFactory.HideProcMgr;
begin
  DeputyProcMgr.Hide;
end;

class procedure TDeputyProcMgrFactory.ShowProcMgr;
begin
  DeputyProcMgr.Show;
end;

end.
