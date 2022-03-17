unit SE.IE.Deputy;

{$WARN SYMBOL_PLATFORM OFF}

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections,
  VCL.Forms, VCL.Menus, System.Win.Registry,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers;

type

  TSEIXSettings = class(TRegistryIniFile)
  strict private
    function KillProcActiveGet: boolean;
    procedure KillProcActiveSet(const Value: boolean);
  public
    property KillProcActive: boolean read KillProcActiveGet write KillProcActiveSet;
  end;

  TSEIAProcessManagerUtil = class
  strict private
    FBDSId: cardinal;
    FActions: TStringList;
    procedure SetBDSId;
    procedure ActionAdd(const AMessage: string);
    function TerminateProcessByID(AProcessID: cardinal): boolean;
  private
    function ImageFileName(const PE: TProcessEntry32): string;
    function ProcessKill(const AProcEntry: TProcessEntry32): boolean;
    procedure ProcessEval(const AProcEntry: TProcessEntry32; AProjectOptions: IOTAProjectOptions);
    function IsRunning(AProjectOptions: IOTAProjectOptions): boolean;
  public
    function ProcessContinue(AProjectOptions: IOTAProjectOptions): boolean;
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
    function BeforeProgramLaunch(const Project: IOTAProject): boolean; override;
  public
    constructor Create(const AWizard: TSEIXDeputyWizard);
  end;

  TSEIXDeputyWizard = class(TIDENotifierOTAWizard)
  const
    nm_tools_menu = 'SE Deputy';
    nm_tools_menuitem = 'miSEDeputyRoot';
    nm_message_group = 'SE Deputy';
    nm_mi_killprocnabled = 'killprocitem';
  strict private
    FProcMgr: TSEIAProcessManagerUtil;
    FToolsMenuRootItem: TMenuItem;
    FSettings: TSEIXSettings;
    FMenuItems: TDictionary<string, TMenuItem>;
    function MenuItemByName(const AItemName: string): TMenuItem;
    procedure MessageKillProcStatus;
  private
    FDebugNotifier: ITOTALNotifier;
    procedure InitToolsMenu;
    procedure OnClickMiKillProcEnabled(Sender: TObject);
    function FindMenuItemFirstLine(const AMenuItem: TMenuItem): integer;
    procedure MessagesAdd(const AMessage: string); overload;
    procedure MessagesAdd(const AMessageList: TStringList); overload;
  protected
    procedure IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
      var ACancel: boolean); override;
    function GetIDString: string; override;
    function GetName: string; override;
    class function GetWizardName: string; override;
    function GetWizardDescription: string; override;
    property Settings: TSEIXSettings read FSettings;
    procedure IDEStarted; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState;
    // function GetMenuText: string;
  end;

//function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPTSTR; nSize: DWORD): DWORD; stdcall;
//  external 'PSAPI.dll' name 'GetProcessImageFileNameW';
function QueryFullProcessImageName(hProcess: THandle; dwFlags: cardinal; lpExeName: PWideChar; Var lpdwSize: cardinal)
  : boolean; StdCall; External 'Kernel32.dll' Name 'QueryFullProcessImageNameW';

{ TSEIAKillRunningAppWizard }

constructor TSEIXDeputyWizard.Create;
begin
  inherited;
  FMenuItems := TDictionary<string, TMenuItem>.Create;
  FDebugNotifier := TSEIADebugNotifier.Create(self);
  FProcMgr := TSEIAProcessManagerUtil.Create;
  FSettings := TSEIXSettings.Create('SOFTWARE\SwiftExpat\Deputy');
  InitToolsMenu;
end;

destructor TSEIXDeputyWizard.Destroy;
begin
  FDebugNotifier.RemoveNotifier;
  FSettings.Free;
  FMenuItems.Free;
  FProcMgr.Free;
  inherited;
end;

function TSEIXDeputyWizard.FindMenuItemFirstLine(const AMenuItem: TMenuItem): integer;
var
  mi: TMenuItem;
  i: integer;
begin
  for i := 0 to AMenuItem.Count - 1 do
  begin
    mi := AMenuItem.Items[i];
    if mi.IsLine then
      exit(i);
  end;
  result := 0;
end;

function TSEIXDeputyWizard.GetIDString: string;
begin
  result := 'SE.IX.Deputy_2.0';
end;

// function TSEIXDeputyWizard.GetMenuText: string;
// begin
// result := 'SE Kill Running';
// end;

function TSEIXDeputyWizard.GetName: string;
begin
  result := GetWizardName;
end;

function TSEIXDeputyWizard.GetState: TWizardState;
begin { TODO : Save this as a setting and switch accordingly }
  result := [wsEnabled]
end;

function TSEIXDeputyWizard.GetWizardDescription: string;
begin
  result := 'Expert provided by SwiftExpat.com .  Deputy works with RunTime ToolKit';
end;

class function TSEIXDeputyWizard.GetWizardName: string;
resourcestring
  nm_wizardname = 'SwiftExpat Deputy';
begin
  result := nm_wizardname;
end;

procedure TSEIXDeputyWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
  var ACancel: boolean);
begin
  TOTAHelper.ClearMessageGroup(nm_message_group);
{$IFDEF DEBUG}
  MessagesAdd('Before Compile');
{$ENDIF}
  if FSettings.KillProcActive and (AIsCodeInsight = false) then
  begin
    ACancel := Not(FProcMgr.ProcessContinue(AProject.ProjectOptions));
    MessagesAdd(FProcMgr.Actions);
  end;
  inherited;
end;

procedure TSEIXDeputyWizard.IDEStarted;
begin
  inherited;
  MessageKillProcStatus;
end;

procedure TSEIXDeputyWizard.InitToolsMenu;
var
  LToolsMenuItem, mi: TMenuItem;
begin
  // Finds the Tools menu in the IDE, and adds its own menu item underneath it
  if TOTAHelper.FindToolsMenu(LToolsMenuItem) then
  begin
    FToolsMenuRootItem := TMenuItem.Create(nil);
    FToolsMenuRootItem.Name := nm_tools_menuitem;
    FToolsMenuRootItem.Caption := nm_tools_menu;
    LToolsMenuItem.Insert(FindMenuItemFirstLine(LToolsMenuItem), FToolsMenuRootItem);
  end;
  mi := MenuItemByName(nm_mi_killprocnabled);
  mi.Caption := 'Kill Process Enabled';
  mi.Checked := FSettings.KillProcActive;
  mi.OnClick := OnClickMiKillProcEnabled;
  FToolsMenuRootItem.Add(mi);
end;

function TSEIXDeputyWizard.MenuItemByName(const AItemName: string): TMenuItem;
begin
  if FMenuItems.TryGetValue(AItemName, result) then
    exit(result)
  else
  begin
    result := TMenuItem.Create(nil);
    result.Name := AItemName;
    FMenuItems.Add(AItemName, result)
  end;
end;

procedure TSEIXDeputyWizard.MessageKillProcStatus;
begin
  if FSettings.KillProcActive then // if it is checked, then trun it false
    MessagesAdd('Deputy Kill Process Enabled')
  else
    MessagesAdd('Deputy Kill Process disabled');

end;

procedure TSEIXDeputyWizard.MessagesAdd(const AMessageList: TStringList);
var
  s: string;
begin
  for s in AMessageList do
    MessagesAdd(s)
end;

procedure TSEIXDeputyWizard.OnClickMiKillProcEnabled(Sender: TObject);
var
  mi: TMenuItem;
begin
  mi := MenuItemByName(nm_mi_killprocnabled);

  if mi.Checked then // if it is checked, then trun it false
    FSettings.KillProcActive := false
  else
    FSettings.KillProcActive := true;
  // read the settings
  mi.Checked := FSettings.KillProcActive;
  MessageKillProcStatus;

end;

procedure TSEIXDeputyWizard.MessagesAdd(const AMessage: string);
begin
  TOTAHelper.AddTitleMessage(AMessage, nm_message_group);
end;

// Invokes TOTAWizard.InitializeWizard, which in turn creates an instance of the add-in, and registers it with the IDE
function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): boolean; stdcall;
begin
  result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TSEIXDeputyWizard);
end;

exports
// Provides a function named WizardEntryPoint that is required by the IDE when loading a DLL-based add-in
  Initialize name WizardEntryPoint;

{ TSEIADebugNotifier }

function TSEIADebugNotifier.BeforeProgramLaunch(const Project: IOTAProject): boolean;
begin
{$IFDEF DEBUG}
  FWizard.MessagesAdd('Before Program Launch');
{$ENDIF}
  if FWizard.Settings.KillProcActive then
  begin
    result := FProcMgr.ProcessContinue(Project.ProjectOptions);
    FWizard.MessagesAdd(FProcMgr.Actions);
  end
  else
    result := true;
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
var //https://stackoverflow.com/questions/59444919/delphi-how-can-i-get-list-of-running-applications-with-starting-path
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
  rLength:=512; // allocation buffer
  SetLength(Result, rLength+1); // for trailing space
  if QueryFullProcessImageName(hProcess, 0, @result[1], rLength) then
    SetLength(result, rLength)
  else
    result := '';
  CloseHandle(hProcess);

end;

function TSEIAProcessManagerUtil.IsRunning(AProjectOptions: IOTAProjectOptions): boolean;
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
      result := true;
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

function TSEIAProcessManagerUtil.ProcessContinue(AProjectOptions: IOTAProjectOptions): boolean;
begin
  FActions.Clear;
  result := TFile.Exists(AProjectOptions.TargetName);
  if result then // file exists, then inspect the proc tree
  begin
    try
      ActionAdd('File Exists, begin eval proc tree');
      result := IsRunning(AProjectOptions);
    except
      on E: Exception do
        result := true; // allow the IDE to do what it did before
    end;
  end
  else // file does not exist, contiue with processing
  begin
    result := true;
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

function TSEIAProcessManagerUtil.ProcessKill(const AProcEntry: TProcessEntry32): boolean;
begin
  result := TerminateProcessByID(AProcEntry.th32ProcessID);
  if result then
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

function TSEIAProcessManagerUtil.TerminateProcessByID(AProcessID: cardinal): boolean;
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

{ TSEIXSettings }

function TSEIXSettings.KillProcActiveGet: boolean;
begin
  result := self.ReadBool('KillProcess', 'Enabled', true);
end;

procedure TSEIXSettings.KillProcActiveSet(const Value: boolean);
begin
  self.WriteBool('KillProcess', 'Enabled', Value);
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSEIXDeputyWizard.RegisterSplash;

end.
