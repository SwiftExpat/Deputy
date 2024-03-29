unit SE.IE.Deputy;

{$WARN SYMBOL_PLATFORM OFF}

interface

const
  MAJ_VER = 2; // Major version nr.
  MIN_VER = 4; // Minor version nr.
  REL_VER = 2; // Release nr.
  BLD_VER = 0; // Build nr.

  // Version history
  // v2.4.1.0 : First Release
  // v2.4.2.0 : Removed line break on license string

  { Built with TOTAL & KASTRI versions:
    KASTRI : fa453cd : https://github.com/DelphiWorlds/Kastri/commit/fa453cd2afaa47739f01133a5f22cf4dc391fc84
    TOTAL : 2ec8360 : https://github.com/DelphiWorlds/TOTAL/commit/2ec8360328bab72b0ade817f1ffd168210f2098e
  }

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

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections, System.DateUtils, System.JSON,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, System.Net.HttpClientComponent, System.Net.URLClient, System.Net.HttpClient, System.Zip,
  frmDeputyProcMgr;

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
    function AgentString: string;
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
    url_domain = '.swiftexpat.com';
    url_demos = 'https://demos' + url_domain;
    url_lic = 'https://licadmin' + url_domain;
    url_demo_downloads = url_demos + '/downloads/';
    url_version = url_lic + '/deputy/';
    url_deputy_version = url_lic + '/deputy/' + fl_nm_deputy_version;

  strict private
    FLicensed: boolean;
    FSettings: TSEIXSettings;
    FWizardInfo: TSEIXWizardInfo;
    FWizardVersion, FUpdateVersion: TSEIXVersionInfo;
    FHTTPReqCaddie, FHTTPReqDemoFMX, FHTTPReqDemoVCL, FHTTPReqDeputyVersion, FHTTPReqDeputyDL: TNetHTTPRequest;
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
    procedure ExpertLogUsage(const AUsageStep: string);
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

  TSEIXDeputyWizard = class;

  TSEIADebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSEIXDeputyWizard;
  strict private
    FProcMgr: TDeputyProcMgr;
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
  FIDEStarted:boolean;
    FProcMgr: TDeputyProcMgr;
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
  FIDEStarted := false;
  FMenuItems := TDictionary<string, TMenuItem>.Create;
  FDebugNotifier := TSEIADebugNotifier.Create(self);
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
begin
  result := [wsEnabled]
end;

function TSEIXDeputyWizard.GetWizardDescription: string;
begin
  result := 'Expert provided by SwiftExpat.com .' + #13 + '  Deputy works with RunTime ToolKit';
end;

class function TSEIXDeputyWizard.GetWizardLicense: string;
begin
  result := 'GPL V3, Commerical via SwiftExpat.com'
  //result := 'GPL V3' + #13 + 'Commerical via SwiftExpat.com'
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
    //ACancel := Not(FProcMgr.IDECancel);//(AProject.ProjectOptions));
   // MessagesAdd(FProcMgr.Actions);
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
  FIDEStarted := true;
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
  if FIDEStarted then //only message if the IDE is started, throws exception on show
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
   // result := FProcMgr.IDECancel;//(Project.ProjectOptions);
    //FWizard.MessagesAdd(FProcMgr.Actions);
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
  //FProcMgr := TSEIAProcessManagerUtil.Create;
  FNagCounter := TSEIXNagCounter.Create(0, 4);
end;

destructor TSEIADebugNotifier.Destroy;
begin
  FNagCounter.Free;
  inherited;
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
{$ELSEIF COMPILERVERSION = 33}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
{$ENDIF}
{$IF COMPILERVERSION > 33}
    FHTTPClient.UseDefaultCredentials := false;
{$ENDIF}
    FHTTPClient.UserAgent := nm_user_agent + ' ' + FWizardInfo.AgentString;
    { TODO : Create a hash of Username / Computer name }
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

procedure TSERTTKCheck.ExpertLogUsage(const AUsageStep: string);
var
  hdr: TNetHeaders;
begin
  InitHttpClient;
  SetLength(hdr, 1);
  hdr[0] := TNameValuePair.Create('Referer', 'LogUsage:' + AUsageStep);
  FHTTPClient.Asynchronous := true;
  FHTTPClient.Head(url_deputy_version, hdr);
  { TODO : Implement exception & success for this? }
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
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(DeputyExpertDownloadFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting Deputy Experts');
    if TZipFile.IsValid(DeputyExpertDownloadFile) then
    begin
      LogMessage('Zip File is valid ' + DeputyExpertDownloadFile);
      TZipFile.ExtractZipFile(DeputyExpertDownloadFile, DeputyWizardUpdatesDirectory);
      LogMessage('Wizard Updates Extracted.');
    end
    else // Zip file invalid
      LogMessage('Zip File not valid ' + DeputyExpertDownloadFile)
  end
  else
    LogMessage('Download Deputy Expert Http result = ' + AResponse.StatusCode.ToString);

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
  InitHttpClient;
  if not Assigned(FHTTPReqDeputyVersion) then
    FHTTPReqDeputyVersion := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDeputyVersion.OnRequestException := HttpDeputyDLException;
  FHTTPReqDeputyVersion.SynchronizeEvents := false;
{$ELSE}
  // FHTTPReqCaddie.OnRequestError := HttpCaddieDLException;
  FHTTPReqDeputyVersion.Asynchronous := true;
{$ENDIF}
  FHTTPReqDeputyVersion.Client := FHTTPClient;
  FHTTPReqDeputyVersion.OnRequestCompleted := HttpDeputyDLCompleted;
  FHTTPReqDeputyVersion.Asynchronous := true;
  FHTTPReqDeputyVersion.Get(url_demo_downloads + fl_nm_deputy_expert_zip);
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
        FSettings.LastUpdateCheck := now;
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
  FHTTPReqDeputyVersion.Free;
  FHTTPReqDeputyDL.Free;
  FHTTPReqCaddie.Free;
  FHTTPReqDemoFMX.Free;
  FHTTPReqDemoVCL.Free;
  FHTTPClient.Free;
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
  begin
    if TZipFile.IsValid(DeputyExpertDownloadFile) then
    begin
      zf := TZipFile.Create;
      try
        try
          zf.Open(DeputyExpertDownloadFile, TZipMode.zmRead);
          zf.Read(fl_nm_deputy_version, zb);//add logging if zb < 20?
          JSONValue := TJSONObject.ParseJSONValue(zb, 0, true);
          if JSONValue is TJSONObject then
          begin    { TODO : replace with JSONValue.TryGetValue to be a little more flexible }
            ma := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_major);
            mi := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_minor);
            re := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_release);
            result := (ma = FUpdateVersion.VerMaj) and (mi = FUpdateVersion.VerMin) and (re = FUpdateVersion.VerRel);
          end
          else // false if the json can not parse
            result := false;
          zf.Close;
        except
          on E: Exception do
            result := false;
        end;
      finally
        zf.Free;
      end;
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
  ExpertLogUsage('Refresh-Updates');
  if Assigned(FWizardVersion) then
    FWizardVersion.Free;

  FWizardVersion := TSEIXVersionInfo.Create;
  FWizardVersion.VerMaj := AWizardInfo.WizardVersion.Split(['.'])[0].ToInteger;
  FWizardVersion.VerMin := AWizardInfo.WizardVersion.Split(['.'])[1].ToInteger;
  FWizardVersion.VerRel := AWizardInfo.WizardVersion.Split(['.'])[2].ToInteger;
  // check the settings for last update dts
  if (HoursBetween(FSettings.LastUpdateCheck, now) < 8) and DeputyVersionFileExists then
  begin
    LogMessage('Using cached values');
    LoadDeputyUpdateVersion;
    FExpertUpdateMenuItem.Caption := UpdateExpertButtonText;
  end
  else
  begin // async download must update button after checking the file
    LogMessage(' checking server for updates');
    HttpDeputyVersionDownload;
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

{ TSEIXWizardInfo }

function TSEIXWizardInfo.AgentString: string;
begin
  result := 'Ver=' + WizardVersion;
  result := result + ' Platform=' + TPath.GetFileName(WizardFileName)
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSEIXDeputyWizard.RegisterSplash;

end.
