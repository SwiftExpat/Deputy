unit SE.ProcMgrUtils;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses System.Classes, Winapi.Windows, Winapi.TlHelp32;

type
  TSEProcessStopCommand = (tseProcStopKill, tseProcStopClose);

  TSEProcessCleanup = class
  public
    StopCommand: TSEProcessStopCommand;
    CloseMemLeak: boolean;
    CopyMemLeak: boolean;
    Timeout: cardinal;
    ProcID: cardinal;
    ProcList: TStringList;
    ProcessName: string;
    ProcessDirectory: string;
    function ProcessFullName: string;
    constructor Create(const AProcName: string; const AProcDirectory: string;
      const AStopCommand: TSEProcessStopCommand);
    destructor Destroy; override;
  end;

  TSEProcessManagerMessage = procedure(AMsg: string) of object;
  TSEProcessManagerWaitPoll = procedure(APollCount: integer) of object;
  TSEProcessManagerLeakCopied = procedure(AMsg: string) of object;

  TSEProcessManagerEnvInfo = class
  strict private
    procedure LoadBDSInfo;
  public
    BDSProcID: cardinal;
    constructor Create;
  end;

  TSEProcessManager = class
  strict private
    FManagerStopped: boolean;
    FProcMgrInfo: TSEProcessManagerEnvInfo;
    FActions: TStringList;
    FCleanup: TSEProcessCleanup;
    FMsgProc: TSEProcessManagerMessage;
    FLeakCopied: TSEProcessManagerLeakCopied;
    FWaitPoll: TSEProcessManagerWaitPoll;
    function TerminateProcessByID(AProcessID: cardinal): boolean;
    procedure LogMsg(const AMsg: string);
  private
    function ImageFileName(const PE: TProcessEntry32): string;
    function ProcessMatched(const AProcEntry: TProcessEntry32): boolean;
    function ProcIDRunning(APID: cardinal): boolean;
    function ProcListLoad: boolean;
    function LeakWindowShowing(APID: cardinal): boolean;
    function LeakWindowClose(APID: cardinal): boolean;
    procedure ExecKill;
    procedure ExecClose;
    function CloseMainWindow(APID: cardinal): boolean;
  public
    function FindMainWindow(const APID: DWord): DWord;
    function FindLeakMsgWindow(const APID: DWord): DWord;
    procedure ProcessCleanup(const ACleanup: TSEProcessCleanup);
    property Actions: TStringList read FActions;
    destructor Destroy; override;
    procedure StopManager;
    procedure AssignMgrInfo(const AMgrInfo: TSEProcessManagerEnvInfo);
    procedure AssignProcCleanup(const AProcCleanup: TSEProcessCleanup);
    property OnMessage: TSEProcessManagerMessage read FMsgProc write FMsgProc;
    property OnLeakCopied: TSEProcessManagerLeakCopied read FLeakCopied write FLeakCopied;
    property OnWaitPoll: TSEProcessManagerWaitPoll read FWaitPoll write FWaitPoll;
  end;

implementation

uses System.SysUtils, System.DateUtils, System.IOUtils, Winapi.Messages, System.Threading;

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

destructor TSEProcessManager.Destroy;
begin
  FCleanup.Free;
  inherited;
end;

procedure TSEProcessManager.ExecKill;
var
  s: string;
begin
  for s in FCleanup.ProcList do
  begin
    if FManagerStopped then
      exit;
    LogMsg('Killing ' + s);
    if TerminateProcessByID(cardinal.Parse(s)) then
      LogMsg('Terminated id ' + s)
    else
      LogMsg('Failed to terminate ID ' + s);
  end;
end;

procedure TSEProcessManager.ExecClose;
var
  s: string;
  PID: cardinal;
  pc: cardinal;
begin
  for s in FCleanup.ProcList do
  begin
    if FManagerStopped then
      exit;
    PID := cardinal.Parse(s);
    LogMsg('Closing Main ' + s);
    CloseMainWindow(PID);
    pc := 0;
    while ProcIDRunning(PID) do
    begin
      if FManagerStopped then
        exit;
      TThread.Sleep(100); // sleep first, close was just sent
      inc(pc);
      if Assigned(FWaitPoll) then
        FWaitPoll(pc);
      LogMsg('Exiting ' + pc.ToString);
      if LeakWindowShowing(PID) then
      begin
        LogMsg('Leak window showing');
        if LeakWindowClose(PID) then
        begin // closed no need to poll any more
          LogMsg('Leak window closed');
          exit;
        end
        else
          LogMsg('Failed Leak window close');
      end;
    end;
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
      if Assigned(FLeakCopied) then
        FLeakCopied('Leak Found');
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

procedure TSEProcessManager.ProcessCleanup(const ACleanup: TSEProcessCleanup);
begin
  FManagerStopped := false;
  if Assigned(FCleanup) then
    FCleanup.Free;
  FCleanup := ACleanup;
  ProcListLoad;
  if FCleanup.ProcList.Count = 0 then
  begin
    LogMsg('Process not found');
    exit;
  end;
  if FCleanup.StopCommand = TSEProcessStopCommand.tseProcStopKill then
    ExecKill
  else if FCleanup.StopCommand = TSEProcessStopCommand.tseProcStopClose then
    ExecClose
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
                FCleanup.ProcList.Add(PE.th32ProcessID.ToString);
          until (Process32Next(hSnapShot, PE) = false);
      end;
      result := FCleanup.ProcList.Count > 0;
    except
      on E: Exception do
        raise Exception.Create('failed snapshot' + E.Message);
    end;
  finally
    CloseHandle(hSnapShot);
  end;

end;

procedure TSEProcessManager.StopManager;
begin
  FManagerStopped := true;
end;

function TSEProcessManager.TerminateProcessByID(AProcessID: cardinal): boolean;
var { https://stackoverflow.com/questions/65286513/how-to-terminate-a-process-tree-delphi }
  hProcess: THandle;
begin
  result := false;
  hProcess := OpenProcess(PROCESS_TERMINATE, false, AProcessID);
  if hProcess > 0 then
    try
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
  ProcList := TStringList.Create;
  CloseMemLeak := true;
  CopyMemLeak := true;
end;

destructor TSEProcessCleanup.Destroy;
begin
  ProcList.Free;
  inherited;
end;

function TSEProcessCleanup.ProcessFullName: string;
begin
  result := TPath.Combine(self.ProcessDirectory, self.ProcessName);
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
    on E: Exception do
      self.BDSProcID := 0; // set it to 0 on error
  end;
end;

end.
