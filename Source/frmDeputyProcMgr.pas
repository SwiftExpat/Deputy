unit frmDeputyProcMgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SE.ProcMgrUtils, SERTTK.DeputyTypes,
  Vcl.CategoryButtons, Vcl.ExtCtrls, Generics.Collections, System.Diagnostics, Vcl.Mask, Vcl.Samples.Spin;

type
  EDeputyProcMgrCreate = class(Exception);

  TDeputyProcMgr = class(TForm)
    memoLeakStatus: TMemo;
    sbMain: TStatusBar;
    lbMgrStatus: TListBox;
    pcWorkarea: TPageControl;
    tsSettings: TTabSheet;
    tsStatus: TTabSheet;
    btnAbortCleanup: TButton;
    btnForceTerminate: TButton;
    tmrCleanupStatus: TTimer;
    gpCleanStatus: TGridPanel;
    lblHdrLoopCount: TLabel;
    lblLoopCount: TLabel;
    lblHdrElapsed: TLabel;
    lblElapsedMS: TLabel;
    tsHistory: TTabSheet;
    lvHist: TListView;
    memoLeakHist: TMemo;
    rgProcStopCommand: TRadioGroup;
    Memo1: TMemo;
    rgProcTermActive: TRadioGroup;
    cbCloseLeakWindow: TCheckBox;
    cbCopyLeakMessage: TCheckBox;
    gpTimeouts: TGridPanel;
    lblHdrTimeouts: TLabel;
    lblWaitPollTimeout: TLabel;
    edtWaitPoll: TSpinEdit;
    lblHdrShowDelay: TLabel;
    edtShowDelay: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAbortCleanupClick(Sender: TObject);
    procedure btnForceTerminateClick(Sender: TObject);
    procedure tmrCleanupStatusTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvHistInfoTip(Sender: TObject; Item: TListItem; var InfoTip: string);
    procedure lvHistSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure rgProcStopCommandClick(Sender: TObject);
    procedure rgProcTermActiveClick(Sender: TObject);
    procedure cbCloseLeakWindowClick(Sender: TObject);
    procedure cbCopyLeakMessageClick(Sender: TObject);
    procedure edtWaitPollChange(Sender: TObject);
    procedure edtShowDelayChange(Sender: TObject);
  strict private
    FProcCleanup: TSEProcessCleanup;
    // FProcMgrInfo: TSEProcessManagerEnvInfo;
    FCleanups: TObjectList<TSEProcessCleanup>;
    FProcMgr: TSEProcessManager;
    FStopWatch: TStopWatch;
    FSettings: TSERTTKDeputySettings;
    FStopCommand: TSEProcessStopCommand;
    procedure ClearLog;
    procedure ClearMemLeak;
    function AddCleanup(const AProcName: string; const AProcDirectory: string): TSEProcessCleanup;
    procedure StatusBarUpdateMessage(AMsg: string);
    procedure StartCleanupStatus;
    procedure StopCleanupStatus;
    procedure UpdateSettings;
  private
    procedure LogMsg(AMessage: string);
    procedure LeakCopied(AMessage: string; APID: cardinal);
    procedure WaitPoll(APollCount: integer; ALoopTime: integer);
    property ProcCleanup: TSEProcessCleanup read FProcCleanup write FProcCleanup;
    // property ProcMgrInfo: TSEProcessManagerEnvInfo read FProcMgrInfo write FProcMgrInfo;
    procedure UpdateCleanHist(AProcCleanup: TSEProcessCleanup);
  public
    /// <summary>
    /// Returns  C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit\RT_Caddie.exe
    /// </summary>
    /// <remarks>
    /// uses RttkAppFolder C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit
    /// </remarks>
    function ClearProcess(const AProcName: string; const AProcDirectory: string): Boolean;
    /// <summary>
    /// Called before IDE Compile
    /// </summary>
    /// <remarks>
    /// return false to contine, ture to cancel
    /// </remarks>
    function CompileContinue(const AProcFullPath: string): Boolean;
    /// <summary>
    /// Called by the IDE Debug launch
    /// </summary>
    /// <remarks>
    /// return true to continue, false to cancel
    /// </remarks>
    function DebugLaunch(const AProcFullPath: string): Boolean;
    procedure AssignSettings(ASettings: TSERTTKDeputySettings);
    procedure ShowSettings;
    // function IDECancel: Boolean;
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

function TDeputyProcMgr.AddCleanup(const AProcName, AProcDirectory: string): TSEProcessCleanup;
var
  tli: TListItem;
begin
  result := TSEProcessCleanup.Create(AProcName, AProcDirectory, FStopCommand);
  result.OptionsSet(FStopCommand, cbCloseLeakWindow.Checked, cbCopyLeakMessage.Checked);
  FCleanups.Add(result);
  tli := TListItem.Create(lvHist.Items);
  lvHist.Items.AddItem(tli, 0);
  tli.Data := result;
  tli.Caption := AProcName;
  tli.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', result.StartTime));
  lvHist.Tag := tli.Index;
end;

procedure TDeputyProcMgr.AssignSettings(ASettings: TSERTTKDeputySettings);
begin
  FSettings := ASettings;
  UpdateSettings;
  edtWaitPoll.Value := FSettings.WaitPollInterval;
  FProcMgr.ProcMgrInfo.WaitPollms := FSettings.WaitPollInterval;
  edtShowDelay.Value := FSettings.ShowWindowDelay;
end;

procedure TDeputyProcMgr.btnAbortCleanupClick(Sender: TObject);
begin
  FProcMgr.CleanupAbort;
end;

procedure TDeputyProcMgr.btnForceTerminateClick(Sender: TObject);
begin
  FProcMgr.CleanupForceTerminate;
end;

procedure TDeputyProcMgr.cbCloseLeakWindowClick(Sender: TObject);
begin
  if cbCloseLeakWindow.Checked then
    FSettings.CloseLeakWindow := true
  else
    FSettings.CloseLeakWindow := false;
  UpdateSettings;
end;

procedure TDeputyProcMgr.cbCopyLeakMessageClick(Sender: TObject);
begin
  if cbCopyLeakMessage.Checked then
    FSettings.CopyLeakMessage := true
  else
    FSettings.CopyLeakMessage := false;
  UpdateSettings;
end;

function TDeputyProcMgr.ClearProcess(const AProcName: string; const AProcDirectory: string): Boolean;
begin
  try
    ProcCleanup := AddCleanup(AProcName, AProcDirectory);
    ClearMemLeak;
    ClearLog;
    FProcMgr.AssignProcCleanup(ProcCleanup);
    // if ProcCleanup.StopCommand = TSEProcessStopCommand.tseProcStopClose then
    // self.Show;
    StartCleanupStatus; // timer to count with the stopwatch
    result := FProcMgr.ProcessCleanup;
    tmrCleanupStatus.Enabled := false; // stop the timer
    UpdateCleanHist(ProcCleanup);
    StopCleanupStatus;
  finally
    tmrCleanupStatus.Enabled := false;
    self.Hide; // hide the form
  end;
end;

// ide is asking if ACancel
// return false to contine, ture to cancel
function TDeputyProcMgr.CompileContinue(const AProcFullPath: string): Boolean;
var
  fn, fd: string;
begin
  result := FProcMgr.ProcFileExists(AProcFullPath, fn, fd);
  if not result then // exit false, IDE continue if the file does not exist
    exit(false);

  ClearProcess(fn, fd);
  result := false;
end;

// return true to continue, false to cancel
function TDeputyProcMgr.DebugLaunch(const AProcFullPath: string): Boolean;
var
  fn, fd: string;
begin
  result := FProcMgr.ProcFileExists(AProcFullPath, fn, fd);
  if not result then // exit true, IDE continue if the file does not exist
    exit(true);

  ClearProcess(fn, fd);
  result := true;
end;

procedure TDeputyProcMgr.edtShowDelayChange(Sender: TObject);
begin
  if (edtShowDelay.Value > edtShowDelay.MinValue) and (edtShowDelay.Value < edtShowDelay.MaxValue) then
  begin
    FSettings.ShowWindowDelay := edtShowDelay.Value;
    Memo1.Lines.Add('Setting show window delay to ' + edtShowDelay.Value.ToString)
  end;
end;

procedure TDeputyProcMgr.edtWaitPollChange(Sender: TObject);
begin
  if (edtWaitPoll.Value > edtWaitPoll.MinValue) and (edtWaitPoll.Value < edtWaitPoll.MaxValue) then
  begin
    FSettings.WaitPollInterval := edtWaitPoll.Value;
    Memo1.Lines.Add('Setting waitpool to ' + edtWaitPoll.Value.ToString)
  end;
end;

procedure TDeputyProcMgr.ClearLog;
begin
  lbMgrStatus.Clear;
end;

procedure TDeputyProcMgr.ClearMemLeak;
begin
  memoLeakStatus.Lines.Clear;
end;

procedure TDeputyProcMgr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // FProcMgr.StopManager;
end;

procedure TDeputyProcMgr.FormCreate(Sender: TObject);
begin
  FCleanups := TObjectList<TSEProcessCleanup>.Create(true);
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
  FProcMgr.OnLeakCopied := LeakCopied;
  FProcMgr.OnWaitPoll := WaitPoll;
end;

procedure TDeputyProcMgr.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
  FCleanups.Free;
end;

procedure TDeputyProcMgr.FormShow(Sender: TObject);
begin
  pcWorkarea.ActivePage := tsStatus;
end;

procedure TDeputyProcMgr.LeakCopied(AMessage: string; APID: cardinal);
begin
  ClearMemLeak;
  Application.ProcessMessages;
  PostMessage(memoLeakStatus.Handle, WM_Paste, 0, 0);
  TThread.Sleep(5); // a few ms to paste
  Application.ProcessMessages;
  TThread.Sleep(5); // a few ms to paste
  if memoLeakStatus.Lines.Text.IndexOf('leak') > -1 then
    ProcCleanup.SetLeakByPID(APID, memoLeakStatus.Lines.Text);
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

procedure TDeputyProcMgr.rgProcStopCommandClick(Sender: TObject);
begin
  FSettings.StopCommand := rgProcStopCommand.ItemIndex;
  UpdateSettings;
end;

procedure TDeputyProcMgr.rgProcTermActiveClick(Sender: TObject);
begin
  if rgProcTermActive.ItemIndex = 0 then
    FSettings.KillProcActive := true
  else
    FSettings.KillProcActive := false;
  UpdateSettings;
end;

procedure TDeputyProcMgr.ShowSettings;
begin
  self.Show;
  pcWorkarea.ActivePage := tsSettings;
end;

procedure TDeputyProcMgr.StartCleanupStatus;
begin
  WaitPoll(0, 0);
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
  StatusBarUpdateMessage('Process terminated in ' + FStopWatch.ElapsedMilliseconds.ToString + 'ms');
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

procedure TDeputyProcMgr.UpdateSettings;
begin
  if FSettings.KillProcActive then
  begin
    rgProcTermActive.ItemIndex := 0;
    rgProcStopCommand.ItemIndex := FSettings.StopCommand;
    FStopCommand := TSEProcessStopCommand(FSettings.StopCommand);
    rgProcStopCommand.Visible := true;
    case FStopCommand of
      tseProcStopKill:
        begin
          cbCloseLeakWindow.Visible := false;
          cbCopyLeakMessage.Visible := false;
        end;
      tseProcStopClose:
        begin
          cbCloseLeakWindow.Checked := FSettings.CloseLeakWindow;
          cbCopyLeakMessage.Checked := FSettings.CopyLeakMessage;
          cbCloseLeakWindow.Visible := true;
          cbCopyLeakMessage.Visible := cbCloseLeakWindow.Checked;
        end;
    end;
  end
  else
  begin
    rgProcTermActive.ItemIndex := 1;
    rgProcStopCommand.Visible := false;
    cbCloseLeakWindow.Visible := false;
    cbCopyLeakMessage.Visible := false;
  end;
end;

procedure TDeputyProcMgr.WaitPoll(APollCount: integer; ALoopTime: integer);
begin
  lblLoopCount.Caption := APollCount.ToString;
  if (APollCount > 1) and (ALoopTime > edtShowDelay.Value) then
    self.Show;
  // else
  // memo1.Lines.Add('Delay show, loop= ' + APollCount.ToString + ' time= '+ ALoopTime.ToString);
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
