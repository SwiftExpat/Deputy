unit SE.IE.Deputy;

{$WARN SYMBOL_PLATFORM OFF}

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils,
  VCL.Forms,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers;

type

  TSEIAProcessManagerUtil = class
  strict private
    FBDSId: cardinal;
    FActions: TStringList;
    procedure SetBDSId;
    procedure ActionAdd(const AMessage: string);
    function TerminateProcessByID(AProcessID: cardinal): Boolean;
  private
    function ImageFileName(const PE: TProcessEntry32): string;
    function ProcessKill(const AProcEntry: TProcessEntry32): Boolean;
    procedure ProcessEval(const AProcEntry: TProcessEntry32; AProjectOptions: IOTAProjectOptions);
    function IsRunning(AProjectOptions: IOTAProjectOptions): Boolean;
  public
    function ProcessContinue(AProjectOptions: IOTAProjectOptions): Boolean;
    property Actions: TStringList read FActions;
    constructor Create;
    destructor Destroy; override;
  end;

  TSEIXDeputyWizard = class;

  TSEIADebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSEIXDeputyWizard;
  strict private
    FProcMgr: TSEIAProcessManagerUtil;
  public
    function BeforeProgramLaunch(const Project: IOTAProject): Boolean; override;
  public
    constructor Create(const AWizard: TSEIXDeputyWizard);
  end;

  TSEIXDeputyWizard = class(TIDENotifierOTAWizard)
  const
    nm_message_group = 'SE Deputy';
  strict private
    FProcMgr: TSEIAProcessManagerUtil;
  private
    FDebugNotifier: ITOTALNotifier;
    procedure MessagesAdd(const AMessage: string); overload;
    procedure MessagesAdd(const AMessageList: TStringList);overload;
  protected
    procedure IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean;
      var ACancel: Boolean); override;
    function GetIDString: string; override;
    function GetName: string; override;
    class function GetWizardName: string; override;
    function GetWizardDescription: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState;
    function GetMenuText: string;
  end;

function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPTSTR; nSize: DWORD): DWORD; stdcall;
  external 'PSAPI.dll' name 'GetProcessImageFileNameW';

{ TSEIAKillRunningAppWizard }

constructor TSEIXDeputyWizard.Create;
begin
  inherited;
  FDebugNotifier := TSEIADebugNotifier.Create(self);
  FProcMgr := TSEIAProcessManagerUtil.Create;
end;

destructor TSEIXDeputyWizard.Destroy;
begin
  FDebugNotifier.RemoveNotifier;
  inherited;
end;

function TSEIXDeputyWizard.GetIDString: string;
begin
  Result := 'SE.IX.Deputy_2.0';
end;

function TSEIXDeputyWizard.GetMenuText: string;
begin
  Result := 'SE Kill Running';
end;

function TSEIXDeputyWizard.GetName: string;
begin
  Result := GetWizardName;
end;

function TSEIXDeputyWizard.GetState: TWizardState;
begin
  Result := [wsEnabled]
end;

function TSEIXDeputyWizard.GetWizardDescription: string;
begin
result := 'Plugin provided by SwiftExpat.com';
end;

class function TSEIXDeputyWizard.GetWizardName: string;
resourcestring
  nm_wizardname = 'SwiftExpat Deputy';
begin
  Result := nm_wizardname;
end;

procedure TSEIXDeputyWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean;
  var ACancel: Boolean);
begin
  TOTAHelper.ClearMessageGroup(nm_message_group);
{$IFDEF DEBUG}
  MessagesAdd('Before Compile');
  {$ENDIF}
  ACancel := Not(FProcMgr.ProcessContinue(AProject.ProjectOptions));
  MessagesAdd(FProcMgr.Actions);
  inherited;

  // Application.MessageBox('some message',   'SGxBuildError', MB_OK or MB_ICONERROR);
end;

procedure TSEIXDeputyWizard.MessagesAdd(const AMessageList: TStringList);
var s:string;
begin
  for s in AMessageList  do
    MessagesAdd(s)
end;

procedure TSEIXDeputyWizard.MessagesAdd(const AMessage: string);
begin
  TOTAHelper.AddTitleMessage(AMessage, nm_message_group);
end;

// Invokes TOTAWizard.InitializeWizard, which in turn creates an instance of the add-in, and registers it with the IDE
function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): Boolean; stdcall;
begin
  Result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TSEIXDeputyWizard);
end;

exports
// Provides a function named WizardEntryPoint that is required by the IDE when loading a DLL-based add-in
  Initialize name WizardEntryPoint;

{ TSEIADebugNotifier }

function TSEIADebugNotifier.BeforeProgramLaunch(const Project: IOTAProject): Boolean;
begin
{$IFDEF DEBUG}
  FWizard.MessagesAdd('Before Process Launch');
{$ENDIF}
  Result := FProcMgr.ProcessContinue(Project.ProjectOptions);
  FWizard.MessagesAdd(FProcMgr.Actions);
end;

constructor TSEIADebugNotifier.Create(const AWizard: TSEIXDeputyWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FProcMgr := TSEIAProcessManagerUtil.Create;
end;

{ TSEIAProcessManagerUtil }

constructor TSEIAProcessManagerUtil.Create;
begin
  SetBDSId;
  FActions := TStringList.Create;
end;

destructor TSEIAProcessManagerUtil.Destroy;
begin
  FActions.Free;
  inherited;
end;

function TSEIAProcessManagerUtil.ImageFileName(const PE: TProcessEntry32): string;
var
  szImageFileName: array [0 .. MAX_PATH] of Char;
  hProcess: THandle;
begin
  Result := PE.szExeFile; // fallback in case the other API calls fail
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, PE.th32ProcessID);
  if (hProcess = 0) then
    exit;
  if (GetProcessImageFileName(hProcess, @szImageFileName[0], MAX_PATH) > 0) then
    Result := szImageFileName;
  CloseHandle(hProcess);

end;

function TSEIAProcessManagerUtil.IsRunning(AProjectOptions: IOTAProjectOptions): Boolean;
var
  hSnapShot: THandle;
  PE: TProcessEntry32;
  tn: string;
begin
  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    try
      tn := TPath.GetFileName(AProjectOptions.TargetName);
      if (hSnapShot <> THandle(-1)) then
      begin
        PE.dwSize := SizeOf(TProcessEntry32);
        if (Process32First(hSnapShot, PE)) then
          repeat // look for match by name
            if (PE.szExeFile = tn) then
              ProcessEval(PE, AProjectOptions);
          until (Process32Next(hSnapShot, PE) = false);
      end;
      Result := true;
    except
      on E: Exception do
        raise Exception.Create('failed snapshot' + E.Message);
    end;
  finally
    CloseHandle(hSnapShot);
  end;
end;

procedure TSEIAProcessManagerUtil.ActionAdd(const AMessage: string);
begin
  FActions.Add(AMessage)
end;

function TSEIAProcessManagerUtil.ProcessContinue(AProjectOptions: IOTAProjectOptions): Boolean;
begin
  FActions.Clear;
  Result := TFile.Exists(AProjectOptions.TargetName);
  if Result then // file exists, then inspect the proc tree
  begin
    try
      ActionAdd('File Exists, begin eval proc tree');
      Result := IsRunning(AProjectOptions);
    except
      on E: Exception do
        Result := true; // allow the IDE to do what it did before
    end;
  end
  else // file does not exist, contiue with processing
  begin
    Result := true;
    ActionAdd('File not found, continue');
  end;
end;

procedure TSEIAProcessManagerUtil.ProcessEval(const AProcEntry: TProcessEntry32; AProjectOptions: IOTAProjectOptions);
begin
  if AProcEntry.th32ParentProcessID = FBDSId then
  begin
    ActionAdd('Process matched by ID ');
    ProcessKill(AProcEntry)
  end
  else if ImageFileName(AProcEntry) = AProjectOptions.TargetName
  then { check if this exe is the same path as the one we are trying to build }
  begin
    ActionAdd('Process matched by ImageName ');
    ProcessKill(AProcEntry)
  end
  else
    ActionAdd('Process not matched ');
end;

function TSEIAProcessManagerUtil.ProcessKill(const AProcEntry: TProcessEntry32): Boolean;
begin
  Result := TerminateProcessByID(AProcEntry.th32ProcessID);
  if Result then
    ActionAdd('Process killed ' + AProcEntry.th32ProcessID.ToString)
  else
    ActionAdd('Process not killed ' + AProcEntry.th32ProcessID.ToString);
end;

procedure TSEIAProcessManagerUtil.SetBDSId;
begin
  FBDSId := GetCurrentProcessID;
  if FBDSId = 0 then
    raise Exception.Create('Could not get proc id');
end;

function TSEIAProcessManagerUtil.TerminateProcessByID(AProcessID: cardinal): Boolean;
var { https://stackoverflow.com/questions/65286513/how-to-terminate-a-process-tree-delphi }
  hProcess: THandle;
begin
  Result := false;
  hProcess := OpenProcess(PROCESS_TERMINATE, false, AProcessID);
  if hProcess > 0 then
    try
      Result := Win32Check(TerminateProcess(hProcess, 0));
    finally
      CloseHandle(hProcess);
    end;
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSEIXDeputyWizard.RegisterSplash;

end.
