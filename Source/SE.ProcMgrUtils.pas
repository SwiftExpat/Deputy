unit SE.ProcMgrUtils;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses System.SysUtils, System.Classes, Winapi.Windows, Winapi.TlHelp32;

{ ******************************************************************** }
{ written by swiftexpat }
{ copyright  ©  2022 }
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
  TSEProcessMgrException = class(exception);
  TSEProcessSnapshotFailed = class(TSEProcessMgrException);

  TSEProcessStopCommand = (tseProcStopKill, tseProcStopClose);

  TSEProcessCleanStatus = class
  strict private
    FMemLeakMessage: string;
    FProcID: cardinal;
    FLeakShown: boolean;
  public
    PollCount: cardinal; // not sure why compiler does not like a prop here
    property ProcID: cardinal read FProcID write FProcID;
    property MemLeakMessage: string read FMemLeakMessage write FMemLeakMessage;
    property LeakShown: boolean read FLeakShown write FLeakShown;
    constructor Create(AProcID: cardinal);
  end;

  TSEProcessCleanup = class
  public
    StopCommand: TSEProcessStopCommand;
    CloseMemLeak: boolean;
    CopyMemLeak: boolean;
    // Timeout: cardinal;   //should have
    ProcID: cardinal;
    ProcList: TStringList;
    ProcessName: string;
    ProcessDirectory: string;
    StartTime, EndTime: TDateTime;
    procedure LeakDetail(AStrings: TStrings);
    function LeakShown: boolean;
    function ProcessFound: boolean;
    function ProcessFullName: string;
    procedure OptionsSet(const AStopCommand: TSEProcessStopCommand; ACloseMemLeak, ACopyMemLeak: boolean);
    procedure SetLeakByPID(APID: cardinal; ALeakMsg: string);
    constructor Create(const AProcName: string; const AProcDirectory: string;
      const AStopCommand: TSEProcessStopCommand);
    destructor Destroy; override;
  end;

  TSEProcessManagerMessage = procedure(AMsg: string) of object;
  TSEProcessManagerWaitPoll = procedure(APollCount: integer; ALoopTime: integer) of object;
  TSEProcessManagerLeakCopied = procedure(AMsg: string; APID: cardinal) of object;

  TSEProcessManagerEnvInfo = class
  strict private
    FBDSProcID: cardinal;
    procedure LoadBDSInfo;
  public
    property BDSProcID: cardinal read FBDSProcID write FBDSProcID;
    constructor Create;
  end;

  TSEProcessManager = class
  strict private
    FCleanupStopped, FForceTerminate: boolean;
    FProcMgrInfo: TSEProcessManagerEnvInfo;
    FActions: TStringList;
    FCleanup: TSEProcessCleanup;
    FMsgProc: TSEProcessManagerMessage;
    FLeakCopied: TSEProcessManagerLeakCopied;
    FWaitPoll: TSEProcessManagerWaitPoll;
    FSleepTime: integer;
    function TerminateProcessByID(AProcessID: cardinal): boolean;
    procedure LogMsg(const AMsg: string);
  private
    function ImageFileName(const PE: TProcessEntry32): string;
    function ProcessMatched(const AProcEntry: TProcessEntry32): boolean;
    function ProcIDRunning(APID: cardinal): boolean;
    function ProcListLoad: boolean;
    function LeakWindowShowing(APID: cardinal): boolean;
    function LeakWindowClose(APID: cardinal): boolean;
    procedure ExecClose;
    procedure ExecKill;
    procedure ExecTerminate(APID: cardinal);
    function LoopTime(ALoopCount: integer): integer;
    function CloseMainWindow(APID: cardinal): boolean;
  public
    function FindMainWindow(const APID: DWord): DWord;
    function FindLeakMsgWindow(const APID: DWord): DWord;
    /// <summary>
    /// Starts the process Cleanup for assigned cleanup
    /// </summary>
    /// <remarks>
    /// always returns true at this point, consider refactoring
    /// </remarks>
    function ProcessCleanup: boolean;
    function ProcFileExists(const AProcFullPath: string; var AFileName: string; var AFileDirectory: string): boolean;
    property Actions: TStringList read FActions;
    constructor Create;
    destructor Destroy; override;
    procedure CleanupAbort;
    procedure CleanupForceTerminate;
    procedure AssignMgrInfo(const AMgrInfo: TSEProcessManagerEnvInfo);
    procedure AssignProcCleanup(const AProcCleanup: TSEProcessCleanup);
    property OnMessage: TSEProcessManagerMessage read FMsgProc write FMsgProc;
    property OnLeakCopied: TSEProcessManagerLeakCopied read FLeakCopied write FLeakCopied;
    property OnWaitPoll: TSEProcessManagerWaitPoll read FWaitPoll write FWaitPoll;
  end;

implementation

uses System.DateUtils, System.IOUtils, Winapi.Messages, System.Threading;

type
  TEnumInfo = record
    ProcessID: DWord;
    HWND: THandle;
  end;

function QueryFullProcessImageName(hProcess: THandle; dwFlags: cardinal; lpExeName: PWideChar; Var lpdwSize: cardinal)
  : boolean; StdCall; External 'Kernel32.dll' Name 'QueryFullProcessImageNameW';

{ Anonymous Functions }

function EnumMainWindow(HWND: DWord; var einfo: TEnumInfo): BOOL; stdcall;
var
  PID: DWord;
  pw, wv, we, saw: boolean;
  style: Long_Ptr;
begin
  // pw := false;
  wv := false;
  we := false;
  saw := false;
  // Get the Pid for the Window
  GetWindowThreadProcessId(HWND, @PID);
  result := PID = einfo.ProcessID;
  if result then // matched by PID
  begin // Inspect the window
    pw := GetParent(HWND) = 0;
    if pw then
    begin
      wv := IsWindowVisible(HWND);
      we := IsWindowEnabled(HWND);
      style := GetWindowLongPtr(HWND, GWL_EXSTYLE);
      if (Long_Ptr(style) and WS_EX_APPWINDOW) = WS_EX_APPWINDOW then
        saw := true;
    end;
    if pw and (wv or we) and saw then
    begin
      result := false;
      einfo.HWND := HWND; // set the handle
    end
    else
      result := true;
  end
  else
    result := true
    // EnumWindows continues until the last top-level window is enumerated or the callback function returns FALSE.
end;

function EnumLeakMsgWindow(HWND: DWord; var einfo: TEnumInfo): BOOL; stdcall;
var
  PID: DWord;
  pw, wv, we, saw: boolean;
  style: Long_Ptr;
begin
  // pw := false;
  wv := false;
  we := false;
  saw := false;
  // Get the Pid for the Window
  GetWindowThreadProcessId(HWND, @PID);
  result := PID = einfo.ProcessID;
  if result then // matched by PID
  begin // Inspect the window
    pw := GetParent(HWND) = 0;
    if pw then
    begin
      wv := IsWindowVisible(HWND);
      we := IsWindowEnabled(HWND);
      style := GetWindowLongPtr(HWND, GWL_EXSTYLE);
      if (Long_Ptr(style) and WS_EX_DLGMODALFRAME) = WS_EX_DLGMODALFRAME then
        saw := true;
    end;
    if pw and (wv or we) and saw then
    begin
      result := false;
      einfo.HWND := HWND; // set the handle
    end
    else
      result := true;
  end
  else
    result := true
    // EnumWindows continues until the last top-level window is enumerated or the callback function returns FALSE.
end;

{ TSEProcessManager }

procedure TSEProcessManager.AssignMgrInfo(const AMgrInfo: TSEProcessManagerEnvInfo);
begin
  FProcMgrInfo := AMgrInfo;
end;

procedure TSEProcessManager.AssignProcCleanup(const AProcCleanup: TSEProcessCleanup);
begin
  self.FCleanup := AProcCleanup;
end;

procedure TSEProcessManager.CleanupAbort;
begin
  FCleanupStopped := true;
end;

procedure TSEProcessManager.CleanupForceTerminate;
begin
  FForceTerminate := true;
  FCleanupStopped := true;
end;

function TSEProcessManager.CloseMainWindow(APID: cardinal): boolean;
var
  mw: DWord;
begin
  result := false;
  mw := FindMainWindow(APID);
  try
    LogMsg('Main Window Handle =' + mw.ToString + ' hex=' + mw.ToHexString);
    result := PostMessage(mw, WM_CLOSE, 0, 0);
  except
    on E: EOSError do
      LogMsg('Error : ' + IntToStr(E.ErrorCode) + E.Message);
  end;
end;

constructor TSEProcessManager.Create;
begin
  FSleepTime := 100;
end;

destructor TSEProcessManager.Destroy;
begin
  // FCleanup.Free; // the thread will not free this any more
  inherited;
end;

procedure TSEProcessManager.ExecKill;
var
  s: string;
begin
  for s in FCleanup.ProcList do
    ExecTerminate(cardinal.Parse(s));
end;

procedure TSEProcessManager.ExecTerminate(APID: cardinal);
begin
  LogMsg('Terminating proc id' + APID.ToString);
  if TerminateProcessByID(APID) then
    LogMsg('Terminated  proc id ' + APID.ToString)
  else // if you ever hit this block, let the ide go?
    LogMsg('Failed to terminate proc ID ' + APID.ToString);
end;

procedure TSEProcessManager.ExecClose;
var
  ps: TSEProcessCleanStatus;
  i: integer;
begin
  for i := 0 to FCleanup.ProcList.Count - 1 do
  begin
    if Assigned(FCleanup.ProcList.Objects[i]) and (FCleanup.ProcList.Objects[i] is TSEProcessCleanStatus) then
      ps := TSEProcessCleanStatus(FCleanup.ProcList.Objects[i])
    else
      exit; // should never get here

    FCleanupStopped := false; // reset the stop flag for each itteration
    FForceTerminate := false;
    LogMsg('Closing main window proc id = ' + ps.ProcID.ToString);
    CloseMainWindow(ps.ProcID);
    ps.PollCount := 0; // loop to display status in the IDE
    while ProcIDRunning(ps.ProcID) do
    begin
      if FCleanupStopped then
      begin // exit on abort
        LogMsg('Abort! Stopping wait loop');
        break;
      end;
      TThread.Sleep(FSleepTime); // sleep first, close was just sent
      inc(ps.PollCount);
      if Assigned(FWaitPoll) then
        FWaitPoll(ps.PollCount, LoopTime(ps.PollCount));
      if LeakWindowShowing(ps.ProcID) then
      begin // what is the workflow, hold the IDE till the leak is closed?
        ps.LeakShown := true;
        LogMsg('Leak window showing');
        if LeakWindowClose(ps.ProcID) then
        begin // closed no need to poll any more
          LogMsg('Leak window closed');
          exit;
        end
        else
          LogMsg('Failed Leak window close');
      end;
    end;
    if FForceTerminate then // check a flag for terminate, then call the kill
      ExecTerminate(ps.ProcID);
  end;
end;

function TSEProcessManager.FindLeakMsgWindow(const APID: DWord): DWord;
var
  einfo: TEnumInfo;
begin
  einfo.ProcessID := APID;
  einfo.HWND := 0;
  // for each window execute EnumWindows proc
  EnumWindows(@EnumLeakMsgWindow, integer(@einfo));
  result := einfo.HWND;
end;

function TSEProcessManager.FindMainWindow(const APID: DWord): DWord;
var
  einfo: TEnumInfo;
begin
  einfo.ProcessID := APID;
  einfo.HWND := 0;
  // for each window execute EnumWindows proc
  EnumWindows(@EnumMainWindow, integer(@einfo));
  result := einfo.HWND;
end;

function TSEProcessManager.ImageFileName(const PE: TProcessEntry32): string;
var // https://stackoverflow.com/questions/59444919/delphi-how-can-i-get-list-of-running-applications-with-starting-path
  hProcess: THandle;
  rLength: cardinal;
begin
  result := PE.szExeFile; // fallback in case the other API calls fail
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, PE.th32ProcessID);
  try
    if (hProcess = 0) then
      exit;
    // if (GetProcessImageFileName(hProcess, @szImageFileName[0], MAX_PATH) > 0) then
    // result := szImageFileName;
    rLength := 512; // allocation buffer
    SetLength(result, rLength + 1); // for trailing space
    if QueryFullProcessImageName(hProcess, 0, @result[1], rLength) then
      SetLength(result, rLength)
    else
      result := '';
  finally
    CloseHandle(hProcess);
  end;
end;

function TSEProcessManager.LeakWindowClose(APID: cardinal): boolean;
var
  mw: DWord;
begin
  result := false;
  mw := FindLeakMsgWindow(APID);
  try
    LogMsg('Leak Window Handle =' + mw.ToString + ' hex=' + mw.ToHexString);
    if FCleanup.CopyMemLeak then
    begin
      result := PostMessage(mw, WM_COPY, 0, 0);
      TThread.Sleep(20); // wait to let the clipboard get copied to
      if Assigned(FLeakCopied) then
        FLeakCopied('Leak Found', APID);
    end;
    result := PostMessage(mw, WM_CLOSE, 0, 0);
  except
    on E: EOSError do
      LogMsg('Error : ' + IntToStr(E.ErrorCode) + E.Message);
  end;
end;

function TSEProcessManager.LeakWindowShowing(APID: cardinal): boolean;
var
  lw: cardinal;
begin
  lw := FindLeakMsgWindow(APID);
  result := lw > 0;
end;

procedure TSEProcessManager.LogMsg(const AMsg: string);
begin
  if Assigned(FMsgProc) then
    FMsgProc(AMsg);
end;

function TSEProcessManager.LoopTime(ALoopCount: integer): integer;
begin
  result := FSleepTime * ALoopCount;
end;

function TSEProcessManager.ProcessCleanup: boolean;
begin
  try
    try
      if ProcListLoad then // includes a check on proc count
      begin
        if FCleanup.StopCommand = TSEProcessStopCommand.tseProcStopClose then
          ExecClose
        else
          ExecKill
      end
      else // snapshot success, FCleanup.ProcList.Count = 0, nothing to clean
        LogMsg('Process not found');
      result := true;
    except
      on E: TSEProcessSnapshotFailed do // if the snapshot fails, let the IDE do what it did before
        exit(true);
      on E: exception do // if the snapshot fails, let the IDE do what it did before
      begin
        LogMsg('Proc Clean Exception =' + E.Message); // log any general exception
        exit(true);
      end;
    end;
  finally
    FCleanup.EndTime := now;
  end;
end;

function TSEProcessManager.ProcessMatched(const AProcEntry: TProcessEntry32): boolean;
begin
  if AProcEntry.th32ParentProcessID = FProcMgrInfo.BDSProcID then
  begin
    LogMsg('Process matched by parent ID and name');
    result := true;
  end
  else if ImageFileName(AProcEntry) = FCleanup.ProcessFullName
  then { check if this exe is the same path as the one we are trying to build }
  begin
    LogMsg('Process matched by ImageName ');
    result := true;
  end
  else
    result := false;
end;

function TSEProcessManager.ProcFileExists(const AProcFullPath: string; var AFileName: string;
  var AFileDirectory: string): boolean;
begin
  result := TFile.Exists(AProcFullPath, true);
  if result then
  begin
    AFileName := TPath.GetFileName(AProcFullPath);
    AFileDirectory := TPath.GetDirectoryName(AProcFullPath);
  end;
end;

function TSEProcessManager.ProcIDRunning(APID: cardinal): boolean;
var
  hSnapShot: THandle;
  PE: TProcessEntry32;
begin
  result := false;
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    if (hSnapShot <> THandle(-1)) then
    begin
      PE.dwSize := SizeOf(TProcessEntry32);
      if (Process32First(hSnapShot, PE)) then
        repeat // look for match by name
          if PE.th32ProcessID = APID then
            exit(true);
        until (Process32Next(hSnapShot, PE) = false);
    end;
  finally
    CloseHandle(hSnapShot);
  end;
end;

function TSEProcessManager.ProcListLoad: boolean;
var
  hSnapShot: THandle;
  PE: TProcessEntry32;
begin
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    try
      if (hSnapShot <> THandle(-1)) then
      begin
        PE.dwSize := SizeOf(TProcessEntry32);
        if (Process32First(hSnapShot, PE)) then
          repeat // look for match by name
            if (PE.szExeFile = FCleanup.ProcessName) then
              if ProcessMatched(PE) then
                FCleanup.ProcList.AddObject(PE.th32ProcessID.ToString, TSEProcessCleanStatus.Create(PE.th32ProcessID));
          until (Process32Next(hSnapShot, PE) = false);
      end;
      result := FCleanup.ProcList.Count > 0;
    except
      on E: exception do
      begin
        LogMsg('failed snapshot' + E.Message);
        raise TSEProcessSnapshotFailed.Create('failed snapshot' + E.Message);
      end;
    end;
  finally
    CloseHandle(hSnapShot);
  end;
end;

function TSEProcessManager.TerminateProcessByID(AProcessID: cardinal): boolean;
var { https://stackoverflow.com/questions/65286513/how-to-terminate-a-process-tree-delphi }
  hProcess: THandle;
begin
  result := false;
  hProcess := OpenProcess(PROCESS_TERMINATE, false, AProcessID); // this can throw exception?
  try
    if hProcess > 0 then
      result := Win32Check(TerminateProcess(hProcess, 0));
  finally
    CloseHandle(hProcess);
  end;
end;

{ TSEProcessCleanupOptions }

constructor TSEProcessCleanup.Create(const AProcName: string; const AProcDirectory: string;
  const AStopCommand: TSEProcessStopCommand);
begin
  ProcessName := AProcName;
  ProcessDirectory := AProcDirectory;
  StopCommand := AStopCommand;
  ProcList := TStringList.Create(true); // refactor to generic object list for less type casting
  CloseMemLeak := true;
  CopyMemLeak := true;
  StartTime := now;
end;

destructor TSEProcessCleanup.Destroy;
begin
  ProcList.Free;
  inherited;
end;

procedure TSEProcessCleanup.LeakDetail(AStrings: TStrings);
var
  pcs: TSEProcessCleanStatus;
  i: integer;
begin
  for i := 0 to ProcList.Count - 1 do
    if Assigned(ProcList.Objects[i]) and (ProcList.Objects[i] is TSEProcessCleanStatus) then
    begin
      pcs := TSEProcessCleanStatus(ProcList.Objects[i]);
      AStrings.Add(pcs.MemLeakMessage);
    end;

end;

function TSEProcessCleanup.LeakShown: boolean;
var
  i: integer;
begin
  if ProcessFound then
  begin
    for i := 0 to ProcList.Count - 1 do
      if TSEProcessCleanStatus(ProcList.Objects[i]).LeakShown then
        exit(true);
    result := false;
  end
  else
    result := false;
end;

procedure TSEProcessCleanup.OptionsSet(const AStopCommand: TSEProcessStopCommand; ACloseMemLeak, ACopyMemLeak: boolean);
begin
  StopCommand := AStopCommand;
  CloseMemLeak := ACloseMemLeak;
  CopyMemLeak := ACopyMemLeak;
end;

function TSEProcessCleanup.ProcessFound: boolean;
begin
  result := ProcList.Count > 0;
end;

function TSEProcessCleanup.ProcessFullName: string;
begin
  result := TPath.Combine(self.ProcessDirectory, self.ProcessName);
end;

procedure TSEProcessCleanup.SetLeakByPID(APID: cardinal; ALeakMsg: string);
var
  i: integer;
  // cs: TSEProcessCleanStatus;
begin
  i := ProcList.IndexOf(APID.ToString);
  if i > -1 then
    if Assigned(ProcList.Objects[i]) and (ProcList.Objects[i] is TSEProcessCleanStatus) then
      TSEProcessCleanStatus(ProcList.Objects[i]).MemLeakMessage := ALeakMsg;
end;

{ TSEProcessManagerEnvInfo }

constructor TSEProcessManagerEnvInfo.Create;
begin
  LoadBDSInfo;
end;

procedure TSEProcessManagerEnvInfo.LoadBDSInfo;
begin
  try
    self.BDSProcID := GetCurrentProcessID;
  except // if this does not work IDE / Windows needs a restart
    on E: exception do
      self.BDSProcID := 0; // set it to 0 on error
  end;
end;

{ TSEProcessCleanStatus }

constructor TSEProcessCleanStatus.Create(AProcID: cardinal);
begin
  FProcID := AProcID;
end;

end.
