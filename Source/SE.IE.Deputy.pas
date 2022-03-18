unit SE.IE.Deputy;

{$WARN SYMBOL_PLATFORM OFF}

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, System.Net.HttpClientComponent, System.Net.URLClient, System.Net.HttpClient, System.Zip;

type

  TSEIXSettings = class(TRegistryIniFile)
  strict private
    function KillProcActiveGet: boolean;
    procedure KillProcActiveSet(const Value: boolean);
  public
    property KillProcActive: boolean read KillProcActiveGet write KillProcActiveSet;
  end;

  TSECaddieCheckOnMessage = procedure(const AMessage: string) of object;

  TSECaddieCheck = class
  const
    dl_fl_name = 'SERTTK_Caddie_dl.zip';
  strict private
    FLicensed: boolean;
    FHTTPReqCaddie: TNetHTTPRequest;
    FHTTPClientCaddie: TNetHTTPClient;
    FOnMessage: TSECaddieCheckOnMessage;
    function CaddieAppFile: string;
    function CaddieDownloadFile: string;
    function CaddieAppExists: boolean;
    function CaddieAppFolderExists(const ACreateFolder: boolean): boolean;
    function CaddieAppFolder: string;
    function CaddieIniFile: string;
    function CaddieIniFileExists: boolean;
    procedure LogMessage(AMessage: string);
    procedure RunCaddie;

    procedure DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType; const ARealm, AURL: string;
      var AUserName, APassword: string; var AbortAuth: boolean; var Persistence: TAuthPersistenceType);
    procedure HttpCaddieDLException(const Sender: TObject; const AError: Exception);
    procedure HttpCaddieDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
  public
    procedure DownloadCaddie;
    property Downloaded: boolean read CaddieAppExists;
    property Executed: boolean read CaddieIniFileExists;
    property Licensed: boolean read FLicensed write FLicensed;
    function CaddieButtonText: string;
    procedure OnClickCaddieRun(Sender: TObject);
    property OnMessage: TSECaddieCheckOnMessage read FOnMessage write FOnMessage;
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
    FNagCount: cardinal;
    procedure CheckNagCount;
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
    nm_mi_run_caddie = 'caddierunitem';
  strict private
    FProcMgr: TSEIAProcessManagerUtil;
    FToolsMenuRootItem: TMenuItem;
    FSettings: TSEIXSettings;
    FCaddieCheck: TSECaddieCheck;
    FMenuItems: TDictionary<string, TMenuItem>;
    function MenuItemByName(const AItemName: string): TMenuItem;
    procedure MessageKillProcStatus;
    procedure MessageCaddieCheck(const AMessage: string);
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
    procedure NagCountReached;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState;
    // function GetMenuText: string;
  end;

  // function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPTSTR; nSize: DWORD): DWORD; stdcall;
  // external 'PSAPI.dll' name 'GetProcessImageFileNameW';
function QueryFullProcessImageName(hProcess: THandle; dwFlags: cardinal; lpExeName: PWideChar; Var lpdwSize: cardinal)
  : boolean; StdCall; External 'Kernel32.dll' Name 'QueryFullProcessImageNameW';

{ TSEIAKillRunningAppWizard }

constructor TSEIXDeputyWizard.Create;
begin
  inherited;
  FMenuItems := TDictionary<string, TMenuItem>.Create;
  FDebugNotifier := TSEIADebugNotifier.Create(self);
  FProcMgr := TSEIAProcessManagerUtil.Create;
  FCaddieCheck := TSECaddieCheck.Create;
  FSettings := TSEIXSettings.Create('SOFTWARE\SwiftExpat\Deputy');
  InitToolsMenu;
end;

destructor TSEIXDeputyWizard.Destroy;
begin
  FDebugNotifier.RemoveNotifier;
  FSettings.Free;
  FMenuItems.Free;
  FProcMgr.Free;
  FCaddieCheck.Free;
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
  result := 'com.swiftexpat.deputy';
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
  result := 'Expert provided by SwiftExpat.com .' + #13 + '  Deputy works with RunTime ToolKit';
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
  mi := MenuItemByName(nm_mi_run_caddie);
  mi.Caption := FCaddieCheck.CaddieButtonText;
  mi.OnClick := FCaddieCheck.OnClickCaddieRun;
  FCaddieCheck.OnMessage := MessageCaddieCheck;
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

procedure TSEIXDeputyWizard.MessageCaddieCheck(const AMessage: string);
begin
  MessagesAdd(AMessage);
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

procedure TSEIXDeputyWizard.NagCountReached;
var
  i: integer;
  mi : TMenuItem;
begin
  if FCaddieCheck.Downloaded then
    MessagesAdd('Ready to execute, please try RunTime ToolKit')
  else
    case MessageDlg('Are you ready to download RunTime ToolKit Caddie?', mtConfirmation, [mbOK, mbCancel], 0) of
      mrOk:
      begin
        FCaddieCheck.DownloadCaddie;
        mi := MenuItemByName(nm_mi_run_caddie);
        mi.Caption := FCaddieCheck.CaddieButtonText;
      end;
      mrCancel:
        begin // Write code here for pressing button Cancel
          ShowMessage('Don''t hesitate to contact us when you need more information.');
        end;
    end;
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
  CheckNagCount;
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

procedure TSEIADebugNotifier.CheckNagCount;
begin
  inc(FNagCount);
  if FNagCount = 5 then
  begin
    FNagCount := 0;
{$IFDEF GITHUBEVAL}
    FWizard.NagCountReached;
{$ENDIF}
  end;
end;

constructor TSEIADebugNotifier.Create(const AWizard: TSEIXDeputyWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FProcMgr := TSEIAProcessManagerUtil.Create;
  FNagCount := 0;
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

{ TSECaddieNagCheck }

function TSECaddieCheck.CaddieAppExists: boolean;
begin
  result := TFile.Exists(CaddieAppFile);
end;

function TSECaddieCheck.CaddieAppFile: string;
begin
  result := TPath.Combine(CaddieAppFolder, 'RT_Caddie.exe')
end;

function TSECaddieCheck.CaddieAppFolder: string;
begin
  result := TPath.Combine(TPath.GetCachePath, 'Programs\RunTime_ToolKit2');
end;

function TSECaddieCheck.CaddieAppFolderExists(const ACreateFolder: boolean): boolean;
begin
  if not TDirectory.Exists(CaddieAppFolder) and ACreateFolder then
    TDirectory.CreateDirectory(CaddieAppFolder);
  result := TDirectory.Exists(CaddieAppFolder);
end;

function TSECaddieCheck.CaddieButtonText: string;
begin
  if not CaddieAppExists then
    result := 'Download & Install Caddie'
  else
    result := 'Run Caddie'
end;

function TSECaddieCheck.CaddieDownloadFile: string;
begin
  if CaddieAppFolderExists(true) then
    result := TPath.Combine(CaddieAppFolder, dl_fl_name);
end;

function TSECaddieCheck.CaddieIniFile: string;
begin
  result := TPath.Combine(TPath.GetHomePath, 'RTTK\RTTKCaddie.ini');
end;

function TSECaddieCheck.CaddieIniFileExists: boolean;
begin
  result := TFile.Exists(CaddieIniFile)
end;

procedure TSECaddieCheck.DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType;
  const ARealm, AURL: string; var AUserName, APassword: string; var AbortAuth: boolean;
  var Persistence: TAuthPersistenceType);
begin
  if AnAuthTarget = TAuthTargetType.Server then
  begin
    AUserName := 'DeputyExpert';
    APassword := 'Illbeyourhuckleberry';
  end;
end;

procedure TSECaddieCheck.DownloadCaddie;
begin
  if not Assigned(FHTTPReqCaddie) then
    FHTTPReqCaddie := TNetHTTPRequest.Create(nil);

  if not Assigned(FHTTPClientCaddie) then
  begin // InitHttpClient(FHTTPClientCaddie, FHTTPReqCaddie);
    if not Assigned(FHTTPReqCaddie) then
      raise Exception.Create('Request not assigned');
    if not Assigned(FHTTPClientCaddie) then
      FHTTPClientCaddie := TNetHTTPClient.Create(FHTTPReqCaddie);
    FHTTPClientCaddie.OnAuthEvent := DistServerAuthEvent;
    FHTTPClientCaddie.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
    FHTTPClientCaddie.UseDefaultCredentials := false;
    FHTTPReqCaddie.Client := FHTTPClientCaddie;
  end;

  FHTTPReqCaddie.OnRequestException := HttpCaddieDLException;
  FHTTPReqCaddie.OnRequestCompleted := HttpCaddieDLCompleted;
  FHTTPReqCaddie.SynchronizeEvents := false;
  FHTTPReqCaddie.Asynchronous := true;
  FHTTPReqCaddie.Get('https://swiftexpat.com/downloads/' + dl_fl_name);

end;

procedure TSECaddieCheck.HttpCaddieDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  lfs: TFileStream;
  // lrv: TSEDistReleaseVersion;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(CaddieDownloadFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting');
    if TZipFile.IsValid(CaddieDownloadFile) then
    begin
      LogMessage('Zip File is valid');
      TZipFile.ExtractZipFile(CaddieDownloadFile, self.CaddieAppFolder);
      if TFile.Exists(CaddieAppFile) then
        RunCaddie
      else // for file exists
        LogMessage('Caddie not found after');
    end
    else // Zip file invalid
      LogMessage('Zip File not valid')
  end
  else
    LogMessage('Download Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSECaddieCheck.HttpCaddieDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Server Exception:' + AError.Message;
  // Logger.Critical('Requesting Caddie file failed: ' + msg);

end;

procedure TSECaddieCheck.LogMessage(AMessage: string);
var
  msg: string;
begin
  msg := 'Caddie Check Message: ' + AMessage;
  TThread.Queue(nil,
    procedure
    begin // directly delivering message gives null pointer
      if Assigned(FOnMessage) then
        FOnMessage(msg);
    end);
end;

procedure TSECaddieCheck.OnClickCaddieRun(Sender: TObject);
begin
  if CaddieAppExists then
    RunCaddie
  else
    DownloadCaddie;
end;

procedure TSECaddieCheck.RunCaddie;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(CaddieAppFile);
  shi.lpDirectory := PChar(CaddieAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
  LogMessage('Caddie Running' + shi.lpFile);
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSEIXDeputyWizard.RegisterSplash;

end.
