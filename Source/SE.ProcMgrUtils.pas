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
    Timeout: cardinal;
    ProcID: cardinal;
    ProcList: TStringList;
    ProcessName: string;
    constructor Create(const AProcName: string; const AStopCommand: TSEProcessStopCommand);
  end;

  TSEProcessManagerMessage = procedure(AMsg: string) of object;

  TSEProcessManager = class
  strict private
    FBDSID: cardinal;
    FActions: TStringList;
    FCleanup: TSEProcessCleanup;
    FMsgProc: TSEProcessManagerMessage;
    procedure SetBDSId;
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
    constructor Create;
    destructor Destroy; override;
    property OnMessage: TSEProcessManagerMessage read FMsgProc write FMsgProc;
  end;

implementation

uses System.SysUtils, System.DateUtils, System.IOUtils, Winapi.Messages;

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
  pw := false;
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
  pw := false;
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
  SetBDSId;
end;

destructor TSEProcessManager.Destroy;
begin

  inherited;
end;

procedure TSEProcessManager.ExecKill;
var
  s: string;
begin
  for s in FCleanup.ProcList do
  begin
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
    PID := cardinal.Parse(s);
    LogMsg('Closing Main ' + s);
    CloseMainWindow(PID);
    pc := 0;
    while ProcIDRunning(PID) do
    begin
      TThread.Sleep(100); // sleep first, close was just sent
      inc(pc);
      LogMsg('Running ' + pc.ToString);
      if LeakWindowShowing(PID) then
      begin
        LogMsg('Leak window showing');
        if LeakWindowClose(PID) then
        LogMsg('Leak window closed')
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
  EnumWindows(@EnumLeakMsgWindow, Integer(@einfo));
  result := einfo.HWND;
end;

function TSEProcessManager.FindMainWindow(const APID: DWord): DWord;
var
  einfo: TEnumInfo;
begin
  einfo.ProcessID := APID;
  einfo.HWND := 0;
  // for each window execute EnumWindows proc
  EnumWindows(@EnumMainWindow, Integer(@einfo));
  result := einfo.HWND;
end;

function TSEProcessManager.ImageFileName(const PE: TProcessEntry32): string;
var // https://stackoverflow.com/questions/59444919/delphi-how-can-i-get-list-of-running-applications-with-starting-path
  // szImageFileName: array [0 .. MAX_PATH] of Char;
  hProcess: THandle;
  rLength: cardinal;
begin
  result := PE.szExeFile; // fallback in case the other API calls fail
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, PE.th32ProcessID);
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
  CloseHandle(hProcess);
end;

function TSEProcessManager.LeakWindowClose(APID: cardinal): boolean;
var
  mw: DWord;
begin
  result := false;
  mw := FindLeakMsgWindow(APID);
  try
    LogMsg('Leak Window Handle =' + mw.ToString + ' hex=' + mw.ToHexString);
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

// function TSEProcessManager.ProcessKill(const AProcEntry: TProcessEntry32): boolean;
// begin
// result := TerminateProcessByID(AProcEntry.th32ProcessID);
// if result then
// LogMsg('Process ID ' + AProcEntry.th32ProcessID.ToString + ' killed ' + now.ToString)
// else
// LogMsg('Process not killed ' + AProcEntry.th32ProcessID.ToString);
// end;

function TSEProcessManager.ProcessMatched(const AProcEntry: TProcessEntry32): boolean;
begin
  if AProcEntry.th32ParentProcessID = FBDSID then
  begin
    LogMsg('Process matched by parent ID and name');
    result := true;
  end
  else if ImageFileName(AProcEntry) = FCleanup.ProcessName
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
  tn: string;
begin
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    try
      tn := TPath.GetFileName(FCleanup.ProcessName);
      if (hSnapShot <> THandle(-1)) then
      begin
        PE.dwSize := SizeOf(TProcessEntry32);
        if (Process32First(hSnapShot, PE)) then
          repeat // look for match by name
            if (PE.szExeFile = tn) then
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

procedure TSEProcessManager.SetBDSId;
begin
  FBDSID := GetCurrentProcessID;
  if FBDSID = 0 then
    raise Exception.Create('Could not get proc id');
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

constructor TSEProcessCleanup.Create(const AProcName: string; const AStopCommand: TSEProcessStopCommand);
begin
  ProcessName := AProcName;
  StopCommand := AStopCommand;
  ProcList := TStringList.Create;
end;

end.
