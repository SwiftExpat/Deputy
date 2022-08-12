unit frmDeputyProcMgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SE.ProcMgrUtils, SERTTK.DeputyTypes,
  Vcl.CategoryButtons, Vcl.ExtCtrls, Generics.Collections, System.Diagnostics, Vcl.Mask, Vcl.Samples.Spin;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // Version history
  // v1.0.0.0 : First Release
  // v1.1.0.0 : Moved Settings to dedicated frame on options

  { ******************************************************************** }
  { written by swiftexpat }
  { copyright 2022 }
  { Email : support@swiftexpat.com }
  { Web : https://swiftexpat.com }
  { }
  { The source code is given as is. The author is not responsible }
  { for any possible damage done due to the use of this code. }
  { The complete source code remains property of the author and may }
  { not be distributed, published, given or sold in any form as such. }
  { No parts of the source code can be included in any other component }
  { or application without written authorization of the author. }
  { ******************************************************************** }

type
  EDeputyProcMgrCreate = class(Exception);

  TDeputyProcMgr = class(TForm)
    memoLeakStatus: TMemo;
    sbMain: TStatusBar;
    lbMgrStatus: TListBox;
    pcWorkarea: TPageControl;
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
  FStopCommand := TSEProcessStopCommand(FSettings.StopCommand);
  result := TSEProcessCleanup.Create(AProcName, AProcDirectory, FStopCommand);
  result.OptionsSet(FStopCommand, FSettings.CloseLeakWindow, FSettings.CopyLeakMessage);
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
  FProcMgr.ProcMgrInfo.WaitPollms := FSettings.WaitPollInterval;
end;

procedure TDeputyProcMgr.btnAbortCleanupClick(Sender: TObject);
begin
  FProcMgr.CleanupAbort;
end;

procedure TDeputyProcMgr.btnForceTerminateClick(Sender: TObject);
begin
  FProcMgr.CleanupForceTerminate;
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
  self.Caption := self.Caption + ' v'+Maj_Ver.ToString + '.'+Min_Ver.ToString + '.'+Rel_Ver.ToString;
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

procedure TDeputyProcMgr.WaitPoll(APollCount: integer; ALoopTime: integer);
begin
  lblLoopCount.Caption := APollCount.ToString;
  if (APollCount > 1) and (ALoopTime > FSettings.ShowWindowDelay) then
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
