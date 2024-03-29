unit SE.ProcMgrUtils;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses System.Classes, System.SysUtils, Winapi.Windows, Winapi.TlHelp32;

{ ******************************************************************** }
{ written by swiftexpat }
{ copyright  �  2022 }
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

  ESEProcessMgrException = class(exception);
  ESEProcessSnapshotFailed = class(ESEProcessMgrException);

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
    FWaitPollms: integer;
    procedure LoadBDSInfo;
  public
    property BDSProcID: cardinal read FBDSProcID write FBDSProcID;
    property WaitPollms: integer read FWaitPollms write FWaitPollms;
    constructor Create;
  end;

  TSEProcessInfo = class
  public
    ProcID: cardinal;
    ParentProcID: cardinal;
    ImagePath: string;
    CommandLine: string;
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
    function FindMainWindow(const APID: DWord): DWord;
    function FindLeakMsgWindow(const APID: DWord): DWord;
  public
    /// <summary>
    /// Starts the process Cleanup for assigned cleanup
    /// </summary>
    /// <remarks>
    /// always returns true at this point, consider refactoring
    /// </remarks>
    function ProcessCleanup: boolean;
    /// <summary>
    /// Returns true if file exists and splits to name / directory
    /// </summary>
    function ProcFileExists(const AProcFullPath: string; var AFileName: string; var AFileDirectory: string): boolean;
    /// <summary>
    /// Returns ProcessInfo structure for a PID
    /// </summary>
    function ProcInfo(var AProcInfo: TSEProcessInfo): boolean;
    function ProcessCommandLine(const APID: cardinal; var ACmdLine: string): boolean;
    function ProcessIsSecondInstance(const AProcInfo: TSEProcessInfo; var DupInstance: TSEProcessInfo): boolean;
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Terminates a cleanup loop that would be waiting for close window
    /// </summary>
    procedure CleanupAbort;
    /// <summary>
    /// Terminates cleanup loop and calls terminate process.
    /// </summary>
    procedure CleanupForceTerminate;
    /// <summary>
    ///   Calls terminate process for proc ID
    /// </summary>
    function TerminateProcessByID(AProcessID: cardinal): boolean;
    procedure AssignProcCleanup(const AProcCleanup: TSEProcessCleanup);
    property Actions: TStringList read FActions;
    property ProcMgrInfo: TSEProcessManagerEnvInfo read FProcMgrInfo write FProcMgrInfo;
    property OnMessage: TSEProcessManagerMessage read FMsgProc write FMsgProc;
    property OnLeakCopied: TSEProcessManagerLeakCopied read FLeakCopied write FLeakCopied;
    property OnWaitPoll: TSEProcessManagerWaitPoll read FWaitPoll write FWaitPoll;
  end;

implementation

uses System.DateUtils, System.IOUtils, Winapi.Messages, System.Threading, ActiveX, ComObj;

type
  TEnumInfo = record
    ProcessID: DWord;
    HWND: THANDLE;
  end;

function QueryFullProcessImageName(hProcess: THANDLE; dwFlags: cardinal; lpExeName: PWideChar; Var lpdwSize: cardinal)
  : boolean; StdCall; External 'Kernel32.dll' Name 'QueryFullProcessImageNameW';

function NtQueryInformationProcess(ProcessHandle: THANDLE; ProcessInformationClass: DWord; ProcessInformation: Pointer;
  ProcessInformationLength: ULONG; ReturnLength: PULONG): LongInt; stdcall; external 'ntdll.dll';

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

procedure TSEProcessManager.AssignProcCleanup(const AProcCleanup: TSEProcessCleanup);
begin
  FCleanup := AProcCleanup;
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
  FProcMgrInfo := TSEProcessManagerEnvInfo.Create;
end;

destructor TSEProcessManager.Destroy;
begin
  FProcMgrInfo.Free;
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
      TThread.Sleep(FProcMgrInfo.WaitPollms); // sleep first, close was just sent
      inc(ps.PollCount);
      if Assigned(FWaitPoll) then
        FWaitPoll(ps.PollCount, LoopTime(ps.PollCount));
      if LeakWindowShowing(ps.ProcID) then
      begin // what is the workflow, hold the IDE till the leak is closed?
        if not FCleanup.CloseMemLeak then // Ide can not continue, will go back to default behavior
        begin // break, the leak window is showing
          LogMsg('Done! Review memory leak shown !');
          break;
        end;
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
  hProcess: THANDLE;
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
  result := FProcMgrInfo.WaitPollms * ALoopCount;
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
      on E: ESEProcessSnapshotFailed do // if the snapshot fails, let the IDE do what it did before
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

function TSEProcessManager.ProcessCommandLine(const APID: cardinal; var ACmdLine: string): boolean;
var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;
  FWbemObjectSet: OLEVariant;
begin;
  try
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
    // if the pid not exist a EOleException exception will be raised with the code $80041002 - Object Not Found
    FWbemObjectSet := FWMIService.Get(Format('Win32_Process.Handle="%d"', [APID]));
    ACmdLine := FWbemObjectSet.CommandLine;
    result := true;
  except
    on E: exception do
    begin
      result := false;
      LogMsg('Failed WMI Call:' + E.Message);
    end;
  end;
end;

function TSEProcessManager.ProcessIsSecondInstance(const AProcInfo: TSEProcessInfo;
  var DupInstance: TSEProcessInfo): boolean;
var
  hSnapShot: THANDLE;
  PE: TProcessEntry32;
begin
  result := false;
  if not Assigned(DupInstance) then
    DupInstance := TSEProcessInfo.Create;

  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    if (hSnapShot <> THANDLE(-1)) then
    begin
      PE.dwSize := SizeOf(TProcessEntry32);
      if (Process32First(hSnapShot, PE)) then
        repeat // look for match by name
        begin
          // all matches should be from the same explorer.exe as parent proc ID
          if PE.th32ParentProcessID <> AProcInfo.ParentProcID then
            continue;

          DupInstance.ImagePath := ImageFileName(PE);
          DupInstance.ProcID := PE.th32ProcessID;
          if (DupInstance.ProcID <> AProcInfo.ProcID) and (AProcInfo.ImagePath = DupInstance.ImagePath) then
          begin
            LogMsg('Matched image path, comparing command lines');
            if ProcessCommandLine(DupInstance.ProcID, DupInstance.CommandLine) then
            begin
              if DupInstance.CommandLine = AProcInfo.CommandLine then
              begin
                LogMsg('Second instance found');
                exit(true);
              end
              else
                LogMsg('Command lines differ');
            end;
          end;
        end;
        until (Process32Next(hSnapShot, PE) = false);
    end;
  finally
    CloseHandle(hSnapShot);
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
  hSnapShot: THANDLE;
  PE: TProcessEntry32;
begin
  result := false;
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    if (hSnapShot <> THANDLE(-1)) then
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

// https://theroadtodelphi.com/2011/07/20/two-ways-to-get-the-command-line-of-another-process-using-delphi/
function TSEProcessManager.ProcInfo(var AProcInfo: TSEProcessInfo): boolean;
var
  ProcessHandle, SnapshotHandle: THANDLE;
  rLength: cardinal;
  PE: TProcessEntry32;
begin
  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, AProcInfo.ProcID);
  SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    if (ProcessHandle = 0) then
      exit(false);
    rLength := 512; // allocation buffer
    SetLength(AProcInfo.ImagePath, rLength + 1); // for trailing space
    result := QueryFullProcessImageName(ProcessHandle, 0, @AProcInfo.ImagePath[1], rLength);
    if result then
      SetLength(AProcInfo.ImagePath, rLength)
    else
      AProcInfo.ImagePath := '';
    // read the command line
    result := ProcessCommandLine(AProcInfo.ProcID, AProcInfo.CommandLine);

    if (SnapshotHandle <> THANDLE(-1)) then
    begin
      PE.dwSize := SizeOf(TProcessEntry32);
      if (Process32First(SnapshotHandle, PE)) then
        repeat // look for match by name
          if PE.th32ProcessID = AProcInfo.ProcID then
          begin
            AProcInfo.ParentProcID := PE.th32ParentProcessID;
            break;
          end;
        until (Process32Next(SnapshotHandle, PE) = false);
    end;

  finally
    CloseHandle(ProcessHandle);
    CloseHandle(SnapshotHandle);
  end;
end;

function TSEProcessManager.ProcListLoad: boolean;
var
  hSnapShot: THANDLE;
  PE: TProcessEntry32;
begin
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    try
      if (hSnapShot <> THANDLE(-1)) then
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
        raise ESEProcessSnapshotFailed.Create('failed snapshot' + E.Message);
      end;
    end;
  finally
    CloseHandle(hSnapShot);
  end;
end;

function TSEProcessManager.TerminateProcessByID(AProcessID: cardinal): boolean;
var { https://stackoverflow.com/questions/65286513/how-to-terminate-a-process-tree-delphi }
  hProcess: THANDLE;
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
  WaitPollms := 100;
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
