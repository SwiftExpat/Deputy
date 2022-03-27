unit SE.IE.Deputy;

{$WARN SYMBOL_PLATFORM OFF}

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections, System.DateUtils, System.JSON,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, System.Net.HttpClientComponent, System.Net.URLClient, System.Net.HttpClient, System.Zip;

type

  TSEIXSettings = class(TRegistryIniFile)
  const
    nm_section_updates = 'Updates';
    nm_section_killprocess = 'KillProcess';
    nm_updates_lastupdate = 'LastUpdateCheckDate';
  strict private
    function KillProcActiveGet: boolean;
    procedure KillProcActiveSet(const Value: boolean);
    function LastUpdateCheckGet: TDateTime;
    procedure LastUpdateCheckSet(const Value: TDateTime);
  public
    property KillProcActive: boolean read KillProcActiveGet write KillProcActiveSet;
    property LastUpdateCheck: TDateTime read LastUpdateCheckGet write LastUpdateCheckSet;
  end;

  TSECaddieCheckOnMessage = procedure(const AMessage: string) of object;
  TSECaddieCheckOnDownloadDone = procedure(const AMessage: string) of object;

  TSEIXWizardInfo = class
  public
    WizardFileName: string; // make this a dynamic call to reflect the rename
    WizardVersion: string;
  end;

  TSEIXVersionInfo = class
  public
    VerMaj: integer;
    VerMin: integer;
    VerRel: integer;
    function VersionString: string;
  end;

  TSERTTKCheck = class
  const
    dl_fl_name = 'SERTTK_Caddie_dl.zip';
    dl_fl_demo_vcl = 'RTTK_Demo_VCL.zip';
    dl_fl_demo_fmx = 'RTTK_Demo_FMX.zip';
    nm_user_agent = 'Deputy Expert';
    fl_nm_demo_vcl = 'RTTK.VCL.exe';
    fl_nm_demo_fmx = 'RTTK_FMX.exe';
    fl_nm_expert_update_cache = 'expertupdates.xml';
    fl_nm_deputy_version = 'deputyversion.json';
    fl_nm_deputy_expert_zip = 'DeputyExpert.zip';
    rk_nm_expert = 'SwiftExpat Deputy';
    nm_json_object = 'DeputyVersion';
    nm_json_prop_major = 'VerMajor';
    nm_json_prop_minor = 'VerMinor';
    nm_json_prop_release = 'VerRelease';
    url_domain =  '.swiftexpat.com';
    url_demos = 'https://demos' + url_domain ;
    url_lic = 'https://licadmin' + url_domain;
    url_demo_downloads = url_demos + '/downloads/';
    url_version = url_lic + '/versions/';

  strict private
    FLicensed: boolean;
    FSettings: TSEIXSettings;
    FWizardInfo: TSEIXWizardInfo;
    FWizardVersion, FUpdateVersion: TSEIXVersionInfo;
    FHTTPReqCaddie, FHTTPReqDemoFMX, FHTTPReqDemoVCL, FHTTPReqDeputyVersion: TNetHTTPRequest;
    FHTTPClient: TNetHTTPClient;
    FOnMessage: TSECaddieCheckOnMessage;
    FOnDownloadDone, FOnDownloadFMXDemoDone, FOnDownloadVCLDemoDone: TSECaddieCheckOnDownloadDone;
    function CaddieAppFile: string;
    function CaddieDownloadFile: string;
    function CaddieAppExists: boolean;
    function DemoVCLExists: boolean;
    function DemoAppVCLFile: string;
    function DemoDownloadVCLFile: string;
    function DeputyExpertDownloadFile: string;
    function DemoFMXExists: boolean;
    function DemoDownloadFMXFile: string;
    // function RttkAppFolderExists(const ACreateFolder: boolean): boolean;
    function RttkDownloadDirectory: string;
    function RttkAppFolder: string;
    function RttkDataDirectory: string;
    function RttkUpdatesDirectory: string;
    function CaddieIniFile: string;
    function CaddieIniFileExists: boolean;
    procedure LogMessage(AMessage: string);
    function DeputyVersionFile: string;
    function DeputyVersionFileExists: boolean;
    function DeputyWizardBackupFilename: string;
    function DeputyWizardUpdateFilename(const AFileName: string): string;
    function DeputyWizardUpdatesDirectory: string;
    procedure RunCaddie;
    procedure RunDemoVCL;
    procedure RunDemoFMX;
    procedure DownloadDemoFMX;
    procedure DownloadDemoVCL;
    procedure InitHttpClient;
    procedure DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType; const ARealm, AURL: string;
      var AUserName, APassword: string; var AbortAuth: boolean; var Persistence: TAuthPersistenceType);
    procedure HttpCaddieDLException(const Sender: TObject; const AError: Exception);
    procedure HttpCaddieDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure HttpDemoVCLDLException(const Sender: TObject; const AError: Exception);
    procedure HttpDemoVCLDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure HttpDemoFMXDLException(const Sender: TObject; const AError: Exception);
    procedure HttpDemoFMXDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure HttpDeputyExpertDownload;
    procedure HttpDeputyVersionDownload;
    procedure HttpDeputyDLException(const Sender: TObject; const AError: Exception);
    procedure HttpDeputyDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure HttpDeputyVersionException(const Sender: TObject; const AError: Exception);
    procedure HttpDeputyVersionCompleted(const Sender: TObject; const AResponse: IHTTPResponse);

  private
    FExpertUpdateMenuItem: TMenuItem;
    function DemoAppFMXFile: string;
    function ExpertFileLocation: string;
    function ExpertUpdateAvailable: boolean;
    function ExpertUpdateDownloaded: boolean;
    procedure ExpertUpdateMenuItemSet(const Value: TMenuItem);
    procedure LoadDeputyUpdateVersion;
    procedure OnClickUpdateExpert(Sender: TObject);
    function UpdateExpertButtonText: string;
  public
    destructor Destroy; override;
    procedure ShowWebsite;
    procedure DownloadCaddie;
    property Downloaded: boolean read CaddieAppExists;
    property Executed: boolean read CaddieIniFileExists;
    property Licensed: boolean read FLicensed write FLicensed;
    function CaddieButtonText: string;
    function DemoVCLButtonText: string;
    function DemoFMXButtonText: string;
    procedure OnClickCaddieRun(Sender: TObject);
    procedure OnClickDemoVCL(Sender: TObject);
    procedure OnClickDemoFMX(Sender: TObject);
    procedure OnClickShowWebsite(Sender: TObject);
    property OnMessage: TSECaddieCheckOnMessage read FOnMessage write FOnMessage;
    property OnDownloadDone: TSECaddieCheckOnDownloadDone read FOnDownloadDone write FOnDownloadDone;
    property OnDownloadDemoVCLDone: TSECaddieCheckOnDownloadDone read FOnDownloadVCLDemoDone
      write FOnDownloadVCLDemoDone;
    property OnDownloadDemoFMXDone: TSECaddieCheckOnDownloadDone read FOnDownloadFMXDemoDone
      write FOnDownloadFMXDemoDone;
    procedure ExpertUpdatesRefresh(const AWizardInfo: TSEIXWizardInfo; const ASettings: TSEIXSettings);
    property ExpertUpdateMenuItem: TMenuItem read FExpertUpdateMenuItem write ExpertUpdateMenuItemSet;
  end;

  TSEIXNagCounter = class
  strict private
    FNagCount, FNagLevel: integer;
  public
    constructor Create(const ANagCount: integer = 0; const ANagLevel: integer = 5);
    function NagUser: boolean;
    procedure NagLess(ANagCount: integer);
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

  // TSEIXUpdateClient = class
  // const
  //
  // strict private
  // FHTTPReqVersion: TNetHTTPRequest;
  // FHTTPClient: TNetHTTPClient;
  // function UpdateFileExists: boolean;
  // public
  // constructor Create;
  // destructor Destroy; override;
  // function UpdateButtonText: string;
  // procedure OnClickUpdate(Sender: TObject);
  // procedure RefreshUpdates;
  // end;

  TSEIXDeputyWizard = class;

  TSEIADebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSEIXDeputyWizard;
  strict private
    FProcMgr: TSEIAProcessManagerUtil;
    FNagCounter: TSEIXNagCounter;
    procedure CheckNagCount;
  public
    function BeforeProgramLaunch(const Project: IOTAProject): boolean; override;
    constructor Create(const AWizard: TSEIXDeputyWizard);
    destructor Destroy; override;
  end;

  TSEIXDeputyWizard = class(TIDENotifierOTAWizard)
  const
    nm_tools_menu = 'SE Deputy';
    nm_tools_menuitem = 'miSEDeputyRoot';
    nm_message_group = 'SE Deputy';
    nm_mi_killprocnabled = 'killprocitem';
    nm_mi_run_caddie = 'caddierunitem';
    nm_mi_run_vcldemo = 'demovclrunitem';
    nm_mi_run_fmxdemo = 'demofmxrunitem';
    nm_mi_show_website = 'showwebsiteitem';
    nm_mi_update_status = 'updatestatusitem';
    nm_wizard_id = 'com.swiftexpat.deputy';
    nm_wizard_display = 'RunTime ToolKit - Deputy';
  strict private
    FProcMgr: TSEIAProcessManagerUtil;
    FToolsMenuRootItem: TMenuItem;
    FSettings: TSEIXSettings;
    FRTTKCheck: TSERTTKCheck;
    FWizardInfo: TSEIXWizardInfo;
    FMenuItems: TDictionary<string, TMenuItem>;
    FNagCounter: TSEIXNagCounter;
    function MenuItemByName(const AItemName: string): TMenuItem;
    // procedure MessageKillProcStatus;
    procedure MenuItemKillProcStatus;
    procedure MessageCaddieCheck(const AMessage: string);
    procedure CaddieCheckDownloaded(const AMessage: string);
    procedure DemoFMXDownloaded(const AMessage: string);
    procedure DemoVCLDownloaded(const AMessage: string);
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
    function GetWizardDescription: string; override;
    property Settings: TSEIXSettings read FSettings;
    procedure IDEStarted; override;
    function NagCountReached: integer;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState;
    class function GetWizardName: string; override;
    class function GetWizardLicense: string; override;
  end;

  // function GetProcessImageFileName(hProcess: THandle; lpImageFileName: LPTSTR; nSize: DWORD): DWORD; stdcall;
  // external 'PSAPI.dll' name 'GetProcessImageFileNameW';
function QueryFullProcessImageName(hProcess: THandle; dwFlags: cardinal; lpExeName: PWideChar; Var lpdwSize: cardinal)
  : boolean; StdCall; External 'Kernel32.dll' Name 'QueryFullProcessImageNameW';

// Invokes TOTAWizard.InitializeWizard, which in turn creates an instance of the add-in, and registers it with the IDE
function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): boolean; stdcall;
begin
  result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TSEIXDeputyWizard);
end;

exports
// Provides a function named WizardEntryPoint that is required by the IDE when loading a DLL-based add-in
  Initialize name WizardEntryPoint;

{ TSEIXDeputyWizard }

constructor TSEIXDeputyWizard.Create;
begin
  inherited;
  FMenuItems := TDictionary<string, TMenuItem>.Create;
  FDebugNotifier := TSEIADebugNotifier.Create(self);
  FProcMgr := TSEIAProcessManagerUtil.Create;
  FRTTKCheck := TSERTTKCheck.Create;
  FNagCounter := TSEIXNagCounter.Create(0, 7);
  FSettings := TSEIXSettings.Create('SOFTWARE\SwiftExpat\Deputy');
  InitToolsMenu;
end;

destructor TSEIXDeputyWizard.Destroy;
begin
  FDebugNotifier.RemoveNotifier;
  FSettings.Free;
  FMenuItems.Free;
  FProcMgr.Free;
  FRTTKCheck.Free;
  FNagCounter.Free;
  FWizardInfo.Free;
  inherited;
end;

function TSEIXDeputyWizard.GetIDString: string;
begin
  result := nm_wizard_id;
end;

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

class function TSEIXDeputyWizard.GetWizardLicense: string;
begin
  result := 'GPL V3' + #13 + 'Commerical via SwiftExpat.com'
end;

class function TSEIXDeputyWizard.GetWizardName: string;
begin
  result := nm_wizard_display;
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
{$IFDEF GITHUBEVAL}
    if FNagCounter.NagUser then
      FNagCounter.NagLess(NagCountReached);
{$ENDIF}
  end;
  inherited;
end;

procedure TSEIXDeputyWizard.IDEStarted;

begin
  inherited;
  MessagesAdd('Deputy Started');

  FWizardInfo := TSEIXWizardInfo.Create;
  FWizardInfo.WizardVersion := GetWizardVersion;
  FWizardInfo.WizardFileName := GetWizardFileName;
  FRTTKCheck.ExpertUpdatesRefresh(FWizardInfo, FSettings);

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
  mi.OnClick := OnClickMiKillProcEnabled;
  FToolsMenuRootItem.Add(mi);
  MenuItemKillProcStatus;
  mi := MenuItemByName(nm_mi_run_caddie);
  mi.Caption := FRTTKCheck.CaddieButtonText;
  mi.OnClick := FRTTKCheck.OnClickCaddieRun;
  FRTTKCheck.OnMessage := MessageCaddieCheck;
  FRTTKCheck.OnDownloadDone := CaddieCheckDownloaded;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_show_website);
  mi.Caption := 'RTTK Website';
  mi.OnClick := FRTTKCheck.OnClickShowWebsite;
  FToolsMenuRootItem.Add(mi);

  mi := MenuItemByName(nm_mi_run_vcldemo);
  mi.Caption := FRTTKCheck.DemoVCLButtonText;
  mi.OnClick := FRTTKCheck.OnClickDemoVCL;
  FRTTKCheck.OnDownloadDemoVCLDone := DemoVCLDownloaded;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_run_fmxdemo);
  mi.Caption := FRTTKCheck.DemoFMXButtonText;
  mi.OnClick := FRTTKCheck.OnClickDemoFMX;
  FRTTKCheck.OnDownloadDemoFMXDone := DemoFMXDownloaded;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_update_status);
  mi.Caption := 'Loading Version'; // FRTTKCheck.UpdateExpertButtonText;
  FRTTKCheck.ExpertUpdateMenuItem := mi;
  FToolsMenuRootItem.Add(mi);
end;

procedure TSEIXDeputyWizard.CaddieCheckDownloaded(const AMessage: string);
begin
  MenuItemByName(nm_mi_run_caddie).Caption := FRTTKCheck.CaddieButtonText;
  MessagesAdd('Caddie Downloaded ' + AMessage);
end;

procedure TSEIXDeputyWizard.DemoFMXDownloaded(const AMessage: string);
begin
  MenuItemByName(nm_mi_run_fmxdemo).Caption := FRTTKCheck.DemoFMXButtonText;
  MessagesAdd('FMX Demo Downloaded : ' + AMessage);
end;

procedure TSEIXDeputyWizard.DemoVCLDownloaded(const AMessage: string);
begin
  MenuItemByName(nm_mi_run_vcldemo).Caption := FRTTKCheck.DemoVCLButtonText;
  MessagesAdd('VCL Demo Downloaded : ' + AMessage);
end;

procedure TSEIXDeputyWizard.MessageCaddieCheck(const AMessage: string);
begin
  MessagesAdd(AMessage);
end;

procedure TSEIXDeputyWizard.MenuItemKillProcStatus;
var
  mi: TMenuItem;
begin
  mi := MenuItemByName(nm_mi_killprocnabled);
  mi.Checked := FSettings.KillProcActive;
  if mi.Checked then
  begin
    mi.Caption := 'Kill Process Enabled';
    MessagesAdd('Deputy Kill Process Enabled');
  end
  else
  begin
    mi.Caption := 'Kill Process Disabled';
    MessagesAdd('Deputy Kill Process disabled');
  end;
end;

procedure TSEIXDeputyWizard.OnClickMiKillProcEnabled(Sender: TObject);
begin
  if FSettings.KillProcActive then // if it is checked, then trun it false
    FSettings.KillProcActive := false
  else
    FSettings.KillProcActive := true;
  // read the settings
  MenuItemKillProcStatus;
end;

procedure TSEIXDeputyWizard.MessagesAdd(const AMessageList: TStringList);
var
  s: string;
begin
  for s in AMessageList do
    MessagesAdd(s)
end;

function TSEIXDeputyWizard.NagCountReached: integer;
const
  m_dl_free = #13 + 'The download is free & is a demo of RunTime ToolKit.';
  t_m_title = 'RunTime ToolKit Caddie not found!';
  t_m_download = 'Are you ready to download RunTime ToolKit Caddie?' + m_dl_free;
  t_m_nag = 'Visit http://swiftexpat.com for more information about RunTime ToolKit.' + m_dl_free;
begin
  result := -1; // some default
  if FRTTKCheck.Downloaded then
  begin { TODO : Add nag behavior if caddie was not run recently }
    MessagesAdd('Ready to execute, please try RunTime ToolKit');
    result := -3; // log a message
  end
  else
    case TaskMessageDlg(t_m_title, t_m_download, mtConfirmation, [mbOK, mbCancel], 0) of
      mrOk:
        begin
          FRTTKCheck.DownloadCaddie;
          result := -4096; // if the IDE runs more than that, wow
        end;
      mrCancel:
        begin // Write code here for pressing button Cancel
          case
{$IF COMPILERVERSION > 33}
            MessageDlg(t_m_nag, mtInformation, [mbOK, mbCancel, mbRetry], 0, mbOK,
            ['Visit Site', 'Cancel', 'Later please'])
{$ELSE}
            MessageDlg(t_m_nag, mtInformation, [mbOK, mbCancel, mbRetry], 0, mbOK)
{$ENDIF} of
            mrOk:
              begin
                FRTTKCheck.ShowWebsite;
                result := -1024; // visited the site, dont bug again for this session
              end;
            mrCancel:
              result := 0; // prompt at next interval
            mrRetry:
              result := -5; // the asked for later
          end;
        end;
    end;
end;

procedure TSEIXDeputyWizard.MessagesAdd(const AMessage: string);
begin
  TOTAHelper.AddTitleMessage(AMessage, nm_message_group);
end;

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
{$IFDEF GITHUBEVAL}
  if FNagCounter.NagUser then
    FNagCounter.NagLess(FWizard.NagCountReached);
{$ENDIF}
end;

constructor TSEIADebugNotifier.Create(const AWizard: TSEIXDeputyWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FProcMgr := TSEIAProcessManagerUtil.Create;
  FNagCounter := TSEIXNagCounter.Create(0, 4);
end;

destructor TSEIADebugNotifier.Destroy;
begin
  FNagCounter.Free;
  inherited;
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
var
  s: TDateTime;
begin
  s := now;
  FActions.Clear; // is this slow?
  result := TFile.Exists(AProjectOptions.TargetName);
  if result then // file exists, then inspect the proc tree
  begin
    try
      ActionAdd('File Exists, begin eval proc tree. T=' + MilliSecondsBetween(s, now).ToString);
      result := IsRunning(AProjectOptions);
      ActionAdd('Termination complete. T=' + MilliSecondsBetween(s, now).ToString);
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
  result := self.ReadBool(nm_section_killprocess, 'Enabled', true);
end;

procedure TSEIXSettings.KillProcActiveSet(const Value: boolean);
begin
  self.WriteBool(nm_section_killprocess, 'Enabled', Value);
end;

function TSEIXSettings.LastUpdateCheckGet: TDateTime;
begin
  result := self.ReadDateTime(nm_section_updates, nm_updates_lastupdate, IncDay(now, -1))
end;

procedure TSEIXSettings.LastUpdateCheckSet(const Value: TDateTime);
begin
  self.WriteDateTime(nm_section_updates, nm_updates_lastupdate, Value);
end;

{ TSECaddieNagCheck }

function TSERTTKCheck.CaddieAppExists: boolean;
begin
  result := TFile.Exists(CaddieAppFile);
end;

function TSERTTKCheck.CaddieAppFile: string;
begin
  result := TPath.Combine(RttkAppFolder, 'RT_Caddie.exe')
end;

function TSERTTKCheck.RttkAppFolder: string;
begin
  result := TPath.Combine(TPath.GetCachePath, 'Programs\RunTime_ToolKit');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

function TSERTTKCheck.RttkDataDirectory: string;
begin
  result := TPath.Combine(TPath.GetHomePath, 'RTTK');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result)
end;

function TSERTTKCheck.RttkDownloadDirectory: string;
begin
  result := TPath.Combine(RttkDataDirectory, 'Downloads');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

function TSERTTKCheck.RttkUpdatesDirectory: string;
begin
  result := TPath.Combine(RttkDataDirectory, 'Updates');
end;

function TSERTTKCheck.CaddieButtonText: string;
begin
  if not CaddieAppExists then
    result := 'Download & Install Caddie'
  else
    result := 'Run Caddie'
end;

function TSERTTKCheck.CaddieDownloadFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, dl_fl_name);
end;

function TSERTTKCheck.CaddieIniFile: string;
begin
  result := TPath.Combine(RttkDataDirectory, 'RTTKCaddie.ini');
end;

function TSERTTKCheck.CaddieIniFileExists: boolean;
begin
  result := TFile.Exists(CaddieIniFile)
end;

function TSERTTKCheck.DemoAppFMXFile: string;
begin
  result := TPath.Combine(RttkAppFolder, fl_nm_demo_fmx)
end;

function TSERTTKCheck.DemoAppVCLFile: string;
begin
  result := TPath.Combine(RttkAppFolder, fl_nm_demo_vcl)
end;

function TSERTTKCheck.DemoDownloadFMXFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, dl_fl_demo_fmx)
end;

function TSERTTKCheck.DemoDownloadVCLFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, dl_fl_demo_vcl)
end;

function TSERTTKCheck.DemoFMXButtonText: string;
begin
  if not DemoFMXExists then
    result := 'Download & Install FMX Demo'
  else
    result := 'Run FMX Demo'
end;

function TSERTTKCheck.DemoFMXExists: boolean;
begin
  result := TFile.Exists(DemoAppFMXFile)
end;

function TSERTTKCheck.DemoVCLButtonText: string;
begin
  if not DemoVCLExists then
    result := 'Download & Install VCL Demo'
  else
    result := 'Run VCL Demo'
end;

function TSERTTKCheck.DemoVCLExists: boolean;
begin
  result := TFile.Exists(DemoAppVCLFile)
end;

procedure TSERTTKCheck.DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType;
  const ARealm, AURL: string; var AUserName, APassword: string; var AbortAuth: boolean;
  var Persistence: TAuthPersistenceType);
begin
  if AnAuthTarget = TAuthTargetType.Server then
  begin
    AUserName := 'DeputyExpert';
    APassword := 'Illbeyourhuckleberry';
  end;
end;

procedure TSERTTKCheck.InitHttpClient;
begin
  if not Assigned(FHTTPClient) then
  begin
    FHTTPClient := TNetHTTPClient.Create(nil);
    FHTTPClient.OnAuthEvent := DistServerAuthEvent;
{$IF COMPILERVERSION > 33}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
{$ELSE}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
{$ENDIF}
    FHTTPClient.UseDefaultCredentials := false;
    FHTTPClient.UserAgent := nm_user_agent;
  end;
end;

procedure TSERTTKCheck.DownloadCaddie;
begin
  InitHttpClient;
  if not Assigned(FHTTPReqCaddie) then
    FHTTPReqCaddie := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqCaddie.OnRequestException := HttpCaddieDLException;
  FHTTPReqCaddie.SynchronizeEvents := false;
{$ELSE}
  // FHTTPReqCaddie.OnRequestError := HttpCaddieDLException;
  FHTTPReqCaddie.Asynchronous := true;
{$ENDIF}
  FHTTPReqCaddie.Client := FHTTPClient;
  FHTTPReqCaddie.OnRequestCompleted := HttpCaddieDLCompleted;
  FHTTPReqCaddie.Asynchronous := true;
  FHTTPReqCaddie.Get('https://swiftexpat.com/downloads/' + dl_fl_name);
end;

procedure TSERTTKCheck.DownloadDemoFMX;
begin
  InitHttpClient;
  if not Assigned(FHTTPReqDemoFMX) then
    FHTTPReqDemoFMX := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDemoFMX.OnRequestException := HttpDemoFMXDLException;
  FHTTPReqDemoFMX.SynchronizeEvents := false;
{$ELSE}
  // FHTTPReqCaddie.OnRequestError := HttpCaddieDLException;
  FHTTPReqDemoFMX.Asynchronous := true;
{$ENDIF}
  FHTTPReqDemoFMX.Client := FHTTPClient;
  FHTTPReqDemoFMX.OnRequestCompleted := HttpDemoFMXDLCompleted;
  FHTTPReqDemoFMX.Asynchronous := true;
  FHTTPReqDemoFMX.Get('https://demos.swiftexpat.com/downloads/' + dl_fl_demo_fmx);
end;

procedure TSERTTKCheck.DownloadDemoVCL;
begin
  InitHttpClient;
  if not Assigned(FHTTPReqDemoVCL) then
    FHTTPReqDemoVCL := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDemoVCL.OnRequestException := HttpDemoVCLDLException;
  FHTTPReqDemoVCL.SynchronizeEvents := false;
{$ELSE}
  // FHTTPReqCaddie.OnRequestError := HttpCaddieDLException;
  FHTTPReqDemoVCL.Asynchronous := true;
{$ENDIF}
  FHTTPReqDemoVCL.Client := FHTTPClient;
  FHTTPReqDemoVCL.OnRequestCompleted := HttpDemoVCLDLCompleted;
  FHTTPReqDemoVCL.Asynchronous := true;
  FHTTPReqDemoVCL.Get('https://demos.swiftexpat.com/downloads/' + dl_fl_demo_vcl);
end;

function TSERTTKCheck.ExpertFileLocation: string;
{ Computer\HKEY_CURRENT_USER\SOFTWARE\Embarcadero\BDS\20.0\Experts }
var
  bk: string;
  reg: TRegistry;
begin
  result := 'err';
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  try
    bk := TOTAHelper.GetRegKey + '\Experts';
    if reg.KeyExists(bk) then
    begin
      reg.OpenKey(bk, false);
      if reg.ValueExists(rk_nm_expert) then
        result := reg.ReadString(rk_nm_expert)
      else
        result := 'not found';
      reg.CloseKey;
    end;

  finally
    reg.Free;
  end;
end;

procedure TSERTTKCheck.HttpCaddieDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  lfs: TFileStream;
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
      TZipFile.ExtractZipFile(CaddieDownloadFile, RttkAppFolder);
      if TFile.Exists(CaddieAppFile) then
      begin
        RunCaddie;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnDownloadDone) then
              OnDownloadDone('Downloaded');
          end);
      end
      else // for file exists
        LogMessage('Caddie not found after');
    end
    else // Zip file invalid
      LogMessage('Zip File not valid')
  end
  else
    LogMessage('Download Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKCheck.HttpCaddieDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Caddie~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKCheck.HttpDemoFMXDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
const
  nm_log_id = 'Demo FMX';
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(DemoDownloadFMXFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting ' + nm_log_id);
    if TZipFile.IsValid(DemoDownloadFMXFile) then
    begin
      LogMessage('Zip File is valid ' + DemoDownloadFMXFile);
      TZipFile.ExtractZipFile(DemoDownloadFMXFile, RttkAppFolder);
      if TFile.Exists(DemoAppFMXFile) then
      begin
        RunDemoFMX;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnDownloadDemoFMXDone) then
              OnDownloadDemoFMXDone('Downloaded ' + nm_log_id);
          end);
      end
      else // for file exists
        LogMessage(nm_log_id + ' not found after extract. ' + DemoAppFMXFile);
    end
    else // Zip file invalid
      LogMessage('Zip File not valid ' + DemoDownloadFMXFile)
  end
  else
    LogMessage('Download ' + nm_log_id + ' Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKCheck.HttpDemoFMXDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Demo FMX~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKCheck.HttpDemoVCLDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
const
  nm_log_id = 'Demo VCL';
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(DemoDownloadVCLFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting ' + nm_log_id);
    if TZipFile.IsValid(DemoDownloadVCLFile) then
    begin
      LogMessage('Zip File is valid ' + DemoDownloadVCLFile);
      TZipFile.ExtractZipFile(DemoDownloadVCLFile, RttkAppFolder);
      if TFile.Exists(DemoAppVCLFile) then
      begin
        RunDemoVCL;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnDownloadDemoVCLDone) then
              OnDownloadDemoVCLDone('Downloaded ' + nm_log_id);
          end);
      end
      else // for file exists
        LogMessage(nm_log_id + ' not found after extract. ' + DemoAppVCLFile);
    end
    else // Zip file invalid
      LogMessage('Zip File not valid ' + DemoDownloadVCLFile)
  end
  else
    LogMessage('Download ' + nm_log_id + ' Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKCheck.HttpDemoVCLDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Demo VCL~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKCheck.HttpDeputyDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin

end;

procedure TSERTTKCheck.HttpDeputyDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Deputy Expert~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKCheck.HttpDeputyExpertDownload;
begin // save the file to downloads

end;

procedure TSERTTKCheck.HttpDeputyVersionCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(DeputyVersionFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Version Complete, Loading');

    TThread.Queue(nil,
      procedure
      begin
        LoadDeputyUpdateVersion;
        FExpertUpdateMenuItem.Caption := UpdateExpertButtonText;
        if ExpertUpdateAvailable and not ExpertUpdateDownloaded then
          HttpDeputyExpertDownload;
      end);
  end
  else
    LogMessage('Download Deputy Version Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKCheck.HttpDeputyVersionDownload;
begin
       InitHttpClient;
  if not Assigned(FHTTPReqDeputyVersion) then
    FHTTPReqDeputyVersion := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDeputyVersion.OnRequestException := HttpDeputyVersionException;
  FHTTPReqDeputyVersion.SynchronizeEvents := false;
{$ELSE}
  // FHTTPReqCaddie.OnRequestError := HttpCaddieDLException;
  FHTTPReqDeputyVersion.Asynchronous := true;
{$ENDIF}
  FHTTPReqDeputyVersion.Client := FHTTPClient;
  FHTTPReqDeputyVersion.OnRequestCompleted := HttpDeputyVersionCompleted;
  FHTTPReqDeputyVersion.Asynchronous := true;
  FHTTPReqDeputyVersion.Get(url_version + fl_nm_deputy_version);
end;

procedure TSERTTKCheck.HttpDeputyVersionException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Deputy Version~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKCheck.LogMessage(AMessage: string);
var
  msg: string;
begin
  msg := 'Msg RTTK Check: ' + AMessage;
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FOnMessage) then
        FOnMessage(msg);
    end);
end;

procedure TSERTTKCheck.OnClickCaddieRun(Sender: TObject);
begin
  if CaddieAppExists then
    RunCaddie
  else
    DownloadCaddie;
end;

procedure TSERTTKCheck.OnClickDemoFMX(Sender: TObject);
begin
  if DemoFMXExists then
    RunDemoFMX
  else
    DownloadDemoFMX;
end;

procedure TSERTTKCheck.OnClickDemoVCL(Sender: TObject);
begin
  if DemoVCLExists then
    RunDemoVCL
  else
    DownloadDemoVCL;
end;

procedure TSERTTKCheck.OnClickShowWebsite(Sender: TObject);
begin
  ShowWebsite;
end;

procedure TSERTTKCheck.RunCaddie;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(CaddieAppFile);
  shi.lpDirectory := PChar(RttkAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
  LogMessage('Caddie Running' + shi.lpFile);
end;

procedure TSERTTKCheck.RunDemoFMX;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(DemoAppFMXFile);
  shi.lpDirectory := PChar(RttkAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
  LogMessage('Demo FMX Running' + shi.lpFile);
end;

procedure TSERTTKCheck.RunDemoVCL;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(DemoAppVCLFile);
  shi.lpDirectory := PChar(RttkAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
  LogMessage('Demo VCL Running' + shi.lpFile);
end;

procedure TSERTTKCheck.ShowWebsite;
const
  ws_link = 'https://swiftexpat.com';
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.lpVerb := PChar('open');
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(ws_link);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
  LogMessage('Caddie Running' + shi.lpFile);

end;

function TSERTTKCheck.DeputyExpertDownloadFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, fl_nm_deputy_expert_zip)
end;

function TSERTTKCheck.DeputyVersionFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, fl_nm_deputy_version)
end;

function TSERTTKCheck.DeputyVersionFileExists: boolean;
begin
  result := TFile.Exists(DeputyVersionFile)
end;

function TSERTTKCheck.DeputyWizardBackupFilename: string;
begin
  result := FWizardInfo.WizardFileName + '.bak';
end;

function TSERTTKCheck.DeputyWizardUpdateFilename(const AFileName: string): string;
var
  fl: string;
begin // match the filename of the expert from the updates dir
  result := '';
  for fl in TDirectory.GetFiles(DeputyWizardUpdatesDirectory, '*.dll', TSearchOption.soTopDirectoryOnly) do
  begin
    if fl.EndsWith(AFileName) then
      exit(fl);
  end;

end;

function TSERTTKCheck.DeputyWizardUpdatesDirectory: string;
begin
  result := TPath.Combine(RttkUpdatesDirectory, 'Deputy');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

destructor TSERTTKCheck.Destroy;
begin
  FWizardVersion.Free;
  FUpdateVersion.Free;
  inherited;
end;

procedure TSERTTKCheck.LoadDeputyUpdateVersion;

var
  JSONValue: TJSONValue;
begin
  if not Assigned(FUpdateVersion) then
    FUpdateVersion := TSEIXVersionInfo.Create;
  FUpdateVersion.VerMaj := -1;
  FUpdateVersion.VerMin := -1;
  FUpdateVersion.VerRel := -1;
  if not DeputyVersionFileExists then
    exit;
  JSONValue := TJSONObject.ParseJSONValue(TFile.ReadAllText(DeputyVersionFile));

  if JSONValue is TJSONObject then
  begin
    FUpdateVersion.VerMaj := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_major);
    FUpdateVersion.VerMin := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_minor);
    FUpdateVersion.VerRel := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_release);
  end;

end;

function TSERTTKCheck.ExpertUpdateAvailable: boolean;
begin
  result := false;
  if FWizardVersion.VerMaj < FUpdateVersion.VerMaj then
  begin
    result := true; // 2021.??.?? vs 2022.??.??
    exit;
  end;

  if (FWizardVersion.VerMaj = FUpdateVersion.VerMaj) then
  begin
    if (FWizardVersion.VerMin < FUpdateVersion.VerMin) then
    begin
      result := true; // 2021.10.?? vs 2021.11.??
      exit;
    end;
    if (FWizardVersion.VerMin = FUpdateVersion.VerMin) then
    begin
      if (FWizardVersion.VerRel < FUpdateVersion.VerRel) then
      begin
        result := true; // 2021.??.?? vs 2022.??.??
        exit;
      end;
    end;
  end
end;

function TSERTTKCheck.ExpertUpdateDownloaded: boolean;
var
  zf: TZipFile;
  ma, mi, re: integer;
  zb: TBytes;
  JSONValue: TJSONValue;
begin
  result := TFile.Exists(DeputyExpertDownloadFile);
  if result then
  begin { TODO : Open the zip file and check the version json to see if it matches, if not download }
    if TZipFile.IsValid(DeputyExpertDownloadFile) then
    begin
      zf := TZipFile.Create;
      zf.Open(DeputyExpertDownloadFile, TZipMode.zmRead);
      zf.Read('fn', zb);
      JSONValue := TJSONObject.ParseJSONValue(zb, 0);
      if JSONValue is TJSONObject then
      begin
        ma := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_major);
        mi := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_minor);
        re := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_release);
      end;
      zf.Close;
      zf.Free;
      result := (ma = FUpdateVersion.VerMaj) and (mi = FUpdateVersion.VerMin) and (re = FUpdateVersion.VerRel);
    end;
  end;
end;

procedure TSERTTKCheck.ExpertUpdateMenuItemSet(const Value: TMenuItem);
begin
  FExpertUpdateMenuItem := Value;
  FExpertUpdateMenuItem.OnClick := OnClickUpdateExpert;
end;

procedure TSERTTKCheck.ExpertUpdatesRefresh(const AWizardInfo: TSEIXWizardInfo; const ASettings: TSEIXSettings);
begin
  FWizardInfo := AWizardInfo;
  FSettings := ASettings;
  if Assigned(FWizardVersion) then
    FWizardVersion.Free;

  FWizardVersion := TSEIXVersionInfo.Create;
  FWizardVersion.VerMaj := AWizardInfo.WizardVersion.Split(['.'])[0].ToInteger;
  FWizardVersion.VerMin := AWizardInfo.WizardVersion.Split(['.'])[1].ToInteger;
  FWizardVersion.VerRel := AWizardInfo.WizardVersion.Split(['.'])[2].ToInteger;
  // check the settings for last update dts
  if HoursBetween(FSettings.LastUpdateCheck, now) > 8 then
  begin // async download must update button after checking the file
    LogMessage(' checking server for updates');
    HttpDeputyVersionDownload;
  end
  else
  begin
    LogMessage('Using cached values');
    LoadDeputyUpdateVersion;
    FExpertUpdateMenuItem.Caption := UpdateExpertButtonText;
  end;
end;

procedure TSERTTKCheck.OnClickUpdateExpert(Sender: TObject);
var
  fn: string;
begin
  // start a download
  // rename dll FWizardInfo.WizardFileName
  try
    if not SameText(ExpertFileLocation, FWizardInfo.WizardFileName) then
    begin // ensure the Update would be for the wizard loaded
      FExpertUpdateMenuItem.Caption := 'Dll missmatch to registry';
      exit;
    end;
    if FWizardInfo.WizardFileName = DeputyWizardBackupFilename then
    begin // pending restart, do not continue
      FExpertUpdateMenuItem.Caption := 'Restart IDE to load update';
      exit;
    end;
    fn := TPath.GetFileName(FWizardInfo.WizardFileName);
    if not TFile.Exists(DeputyWizardUpdateFilename(fn)) then
    begin // no update to install, exit
      FExpertUpdateMenuItem.Caption := 'Update not found';
      exit;
    end;
    if TFile.Exists(DeputyWizardBackupFilename) then
      TFile.Delete(DeputyWizardBackupFilename);
    TFile.Move(FWizardInfo.WizardFileName, DeputyWizardBackupFilename);
    TFile.Move(DeputyWizardUpdateFilename(fn), ExpertFileLocation);
  except
    on E: Exception do
    begin // likely IO related
      FExpertUpdateMenuItem.Caption := 'E:' + E.Message.Substring(0, 20);
      LogMessage('Failed Update ' + E.Message);
    end;
  end;

  FExpertUpdateMenuItem.Caption := 'Restart IDE pending';
end;

function TSERTTKCheck.UpdateExpertButtonText: string;
begin
  if ExpertUpdateAvailable then
    result := 'Update Available to  ' + FUpdateVersion.VersionString
  else
    result := 'Version is current ' + FWizardVersion.VersionString;
end;

{ TSEIXNagCounter }

constructor TSEIXNagCounter.Create(const ANagCount: integer = 0; const ANagLevel: integer = 5);
begin
  FNagCount := ANagCount;
  FNagLevel := ANagLevel;
end;

procedure TSEIXNagCounter.NagLess(ANagCount: integer);
begin
  FNagCount := ANagCount;
end;

function TSEIXNagCounter.NagUser: boolean;
begin
{$IFDEF GITHUBEVAL}
  inc(FNagCount);
{$ENDIF}
  result := FNagLevel = FNagCount;
  if result then
    FNagCount := 0;
end;

{ TSEIXVersionInfo }

function TSEIXVersionInfo.VersionString: string;
begin
  result := VerMaj.ToString + '.' + VerMin.ToString + '.' + VerRel.ToString;
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSEIXDeputyWizard.RegisterSplash;

end.
