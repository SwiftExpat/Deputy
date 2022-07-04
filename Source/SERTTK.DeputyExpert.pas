unit SERTTK.DeputyExpert;

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections, System.DateUtils, System.JSON, frmDeputyProcMgr, frmDeputyUpdates,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, SERTTK.DeputyTypes, SE.ProcMgrUtils;

type
  TSERTTKDeputyWizard = class;

  TSERTTKDeputyDebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSERTTKDeputyWizard;
  strict private
    // FProcMgr: TSEProcessManager;
    FNagCounter: TSERTTKNagCounter;
    // procedure CheckNagCount;
  public
    function BeforeProgramLaunch(const Project: IOTAProject): boolean; override;
    constructor Create(const AWizard: TSERTTKDeputyWizard);
    destructor Destroy; override;
  end;

  TSERTTKDeputyWizard = class(TIDENotifierOTAWizard)
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
    FIDEStarted: boolean;
    FProcMgrForm: TDeputyProcMgr;
    FDeputyUpdates: TDeputyUpdates;
    FToolsMenuRootItem: TMenuItem;
    FSettings: TSERTTKDeputySettings;
    FRTTKAppUpdate: TSERTTKAppVersionUpdate;
    FWizardInfo: TSERTTKWizardInfo;
    FMenuItems: TDictionary<string, TMenuItem>;
    FNagCounter: TSERTTKNagCounter;
    FDeputyUtils: TSERTTKDeputyUtils;
    function MenuItemByName(const AItemName: string): TMenuItem;
    // procedure MessageCaddieCheck(const AMessage: string);
    // procedure CaddieCheckDownloaded(const AMessage: string);
    // procedure DemoFMXDownloaded(const AMessage: string);
    // procedure DemoVCLDownloaded(const AMessage: string);
    procedure OnClickDeputyUpdates(Sender: TObject);
  private
    FDebugNotifier: ITOTALNotifier;
    procedure InitToolsMenu;
    procedure AssignUpdateMenuItems;
    procedure OnClickMiKillProcEnabled(Sender: TObject);
    function FindMenuItemFirstLine(const AMenuItem: TMenuItem): integer;
    procedure MessagesAdd(const AMessage: string); // overload;
    // procedure MessagesAdd(const AMessageList: TStringList); overload;
    procedure OnClickShowWebsite(Sender: TObject);
  protected
    procedure IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
      var ACancel: boolean); override;
    function GetIDString: string; override;
    function GetName: string; override;
    function GetWizardDescription: string; override;
    property Settings: TSERTTKDeputySettings read FSettings;
    procedure IDEStarted; override;
    // function NagCountReached: integer;
    property ProcMgrForm: TDeputyProcMgr read FProcMgrForm;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetState: TWizardState;
    class function GetWizardName: string; override;
    class function GetWizardLicense: string; override;
  end;

  // Invokes TOTAWizard.InitializeWizard, which in turn creates an instance of the add-in, and registers it with the IDE
function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): boolean; stdcall;
begin
  result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TSERTTKDeputyWizard);
end;

exports
// Provides a function named WizardEntryPoint that is required by the IDE when loading a DLL-based add-in
  Initialize name WizardEntryPoint;

{ TSERTTKDeputyWizard }

procedure TSERTTKDeputyWizard.AssignUpdateMenuItems;
var
 mic, mif, miv: TMenuItem;
begin
  mic := MenuItemByName(nm_mi_run_caddie);
  mic.OnClick := FDeputyUpdates.btnUpdateCaddieClick;

  miv := MenuItemByName(nm_mi_run_vcldemo);
  miv.OnClick := FDeputyUpdates.btnUpdateDemoVCLClick;

  mif := MenuItemByName(nm_mi_run_fmxdemo);
  mif.OnClick := FDeputyUpdates.btnUpdateDemoFMXClick;

  FDeputyUpdates.AssignMenuItems(mic, mif, miv);
end;

constructor TSERTTKDeputyWizard.Create;
begin
  inherited;
  FIDEStarted := false;
  FMenuItems := TDictionary<string, TMenuItem>.Create;
  FDebugNotifier := TSERTTKDeputyDebugNotifier.Create(self);
  FRTTKAppUpdate := TSERTTKAppVersionUpdate.Create;
  FNagCounter := TSERTTKNagCounter.Create(0, 7);
  FSettings := TSERTTKDeputySettings.Create(TSERTTKDeputySettings.nm_settings_regkey);
  InitToolsMenu;
end;

destructor TSERTTKDeputyWizard.Destroy;
begin
  FDebugNotifier.RemoveNotifier;
  FSettings.Free;
  FMenuItems.Free;
  FRTTKAppUpdate.Free;
  FNagCounter.Free;
  FWizardInfo.Free;
  FDeputyUtils.Free;
  inherited;
end;

procedure TSERTTKDeputyWizard.IDEStarted;
begin
  inherited;
  FIDEStarted := true;
  MessagesAdd('Deputy Started');
  FWizardInfo := TSERTTKWizardInfo.Create;
  FWizardInfo.WizardVersion := GetWizardVersion;
  FWizardInfo.WizardFileName := GetWizardFileName;
  FDeputyUtils := TSERTTKDeputyUtils.Create;
  FRTTKAppUpdate.AssignWizardInfo(FWizardInfo);
  FRTTKAppUpdate.AssignSettings(FSettings);
  FProcMgrForm := TDeputyProcMgrFactory.DeputyProcMgr;
  FProcMgrForm.AssignSettings(FSettings);
  FDeputyUpdates := TDeputyUpdatesFactory.DeputyUpdates;
  FDeputyUpdates.AssignSettings(FSettings);
  AssignUpdateMenuItems;
  FDeputyUpdates.ExpertUpdatesRefresh(FRTTKAppUpdate);
end;

{$REGION 'Plugin Display values'}

function TSERTTKDeputyWizard.GetIDString: string;
begin
  result := nm_wizard_id;
end;

function TSERTTKDeputyWizard.GetName: string;
begin
  result := nm_wizard_display;
end;

function TSERTTKDeputyWizard.GetState: TWizardState;
begin { TODO : Save this as a setting and switch accordingly }
  result := [wsEnabled]
end;

function TSERTTKDeputyWizard.GetWizardDescription: string;
begin
  result := 'Expert provided by SwiftExpat.com .' + #13 + '  Deputy works with RunTime ToolKit';
end;

class function TSERTTKDeputyWizard.GetWizardLicense: string;
begin
  result := 'GPL V3, Commerical via SwiftExpat.com'
end;

class function TSERTTKDeputyWizard.GetWizardName: string;
begin
  result := nm_wizard_display;
end;

{$ENDREGION}
{$REGION 'Menu Item Helpers'}

function TSERTTKDeputyWizard.FindMenuItemFirstLine(const AMenuItem: TMenuItem): integer;
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

function TSERTTKDeputyWizard.MenuItemByName(const AItemName: string): TMenuItem;
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
{$ENDREGION}
{$REGION 'Message window handlers'}

procedure TSERTTKDeputyWizard.MessagesAdd(const AMessage: string);
begin
  if FIDEStarted then // only message if the IDE is started, throws exception on show
    TOTAHelper.AddTitleMessage(AMessage, nm_message_group);
end;

// procedure TSERTTKDeputyWizard.MessagesAdd(const AMessageList: TStringList);
// var
// s: string;
// begin
// for s in AMessageList do
// MessagesAdd(s)
// end;
{$ENDREGION}

procedure TSERTTKDeputyWizard.InitToolsMenu;
var
  LToolsMenuItem, mi, mic, mif, miv: TMenuItem;
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
  mi.Caption := 'Kill Process Settings';
  FToolsMenuRootItem.Add(mi);
  mic := MenuItemByName(nm_mi_run_caddie);
  mic.Caption := 'Refreshing Caddie';
 // mic.OnClick := FDeputyUpdates.btnUpdateCaddieClick;
  // FRTTKAppUpdate.OnMessage := MessageCaddieCheck;
  // FRTTKAppUpdate.OnDownloadDone := CaddieCheckDownloaded;
  FToolsMenuRootItem.Add(mic);
  mi := MenuItemByName(nm_mi_show_website);
  mi.Caption := 'RTTK Website';
  mi.OnClick := OnClickShowWebsite;
  FToolsMenuRootItem.Add(mi);
  miv := MenuItemByName(nm_mi_run_vcldemo);
  miv.Caption := 'Refreshing Demo VCL';
 // miv.OnClick := FDeputyUpdates.btnUpdateDemoVCLClick;
  // FRTTKAppUpdate.OnDownloadDemoVCLDone := DemoVCLDownloaded;
  FToolsMenuRootItem.Add(miv);
  mif := MenuItemByName(nm_mi_run_fmxdemo);
  mif.Caption := 'Refreshing Demo FMX';
 // mif.OnClick := FDeputyUpdates.btnUpdateDemoFMXClick;
  // FRTTKAppUpdate.OnDownloadDemoFMXDone := DemoFMXDownloaded;
  FToolsMenuRootItem.Add(mif);
 // FDeputyUpdates.AssignMenuItems(mic, mif, miv);
  mi := MenuItemByName(nm_mi_update_status);
  mi.Caption := 'Deputy Updates';
  mi.OnClick := OnClickDeputyUpdates;
  FToolsMenuRootItem.Add(mi);
end;

procedure TSERTTKDeputyWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
  var ACancel: boolean);
begin
  TOTAHelper.ClearMessageGroup(nm_message_group);
  if FSettings.KillProcActive and (AIsCodeInsight = false) then
  begin
    ACancel := FProcMgrForm.CompileContinue(AProject.ProjectOptions.TargetName);
    // {$IFDEF GITHUBEVAL}
    // if FNagCounter.NagUser then
    // FNagCounter.NagLess(NagCountReached);
    // {$ENDIF}
  end;
  inherited;
end;

procedure TSERTTKDeputyWizard.OnClickDeputyUpdates(Sender: TObject);
begin
  TDeputyUpdatesFactory.ShowDeputyUpdates;
end;

procedure TSERTTKDeputyWizard.OnClickMiKillProcEnabled(Sender: TObject);
begin
  FProcMgrForm.ShowSettings;
end;

procedure TSERTTKDeputyWizard.OnClickShowWebsite(Sender: TObject);
begin
  FDeputyUtils.ShowWebsite;
end;

// function TSERTTKDeputyWizard.NagCountReached: integer;
// const
// m_dl_free = #13 + 'The download is free & is a demo of RunTime ToolKit.';
// t_m_title = 'RunTime ToolKit Caddie not found!';
// t_m_download = 'Are you ready to download RunTime ToolKit Caddie?' + m_dl_free;
// t_m_nag = 'Visit http://swiftexpat.com for more information about RunTime ToolKit.' + m_dl_free;
// begin
// result := -1; // some default
// if true then // FRTTKAppUpdate.Downloaded then
// begin { TODO : Add nag behavior if caddie was not run recently }
// MessagesAdd('Ready to execute, please try RunTime ToolKit');
// result := -3; // log a message
// end
// else
// case TaskMessageDlg(t_m_title, t_m_download, mtConfirmation, [mbOK, mbCancel], 0) of
// mrOk:
// begin
// FRTTKAppUpdate.DownloadCaddie;
// result := -4096; // if the IDE runs more than that, wow
// end;
// mrCancel:
// begin // Write code here for pressing button Cancel
// case
// {$IF COMPILERVERSION > 33}
// MessageDlg(t_m_nag, mtInformation, [mbOK, mbCancel, mbRetry], 0, mbOK,
// ['Visit Site', 'Cancel', 'Later please'])
// {$ELSE}
// MessageDlg(t_m_nag, mtInformation, [mbOK, mbCancel, mbRetry], 0, mbOK)
// {$ENDIF} of
// mrOk:
// begin
// // FRTTKAppUpdate.ShowWebsite;
// result := -1024; // visited the site, dont bug again for this session
// end;
// mrCancel:
// result := 0; // prompt at next interval
// mrRetry:
// result := -5; // the asked for later
// end;
// end;
// end;
// end;

{ TSERTTKDeputyDebugNotifier }

function TSERTTKDeputyDebugNotifier.BeforeProgramLaunch(const Project: IOTAProject): boolean;
begin
  // CheckNagCount;
  if FWizard.Settings.KillProcActive then
  begin
    result := FWizard.ProcMgrForm.DebugLaunch(Project.ProjectOptions.TargetName);
    // FWizard.MessagesAdd(FProcMgr.Actions);
  end
  else
    result := true;
end;

// procedure TSERTTKDeputyDebugNotifier.CheckNagCount;
// begin
// {$IFDEF GITHUBEVAL}
// if FNagCounter.NagUser then
// FNagCounter.NagLess(FWizard.NagCountReached);
// {$ENDIF}
// end;

constructor TSERTTKDeputyDebugNotifier.Create(const AWizard: TSERTTKDeputyWizard);
begin
  inherited Create;
  FWizard := AWizard;
  FNagCounter := TSERTTKNagCounter.Create(0, 4);
end;

destructor TSERTTKDeputyDebugNotifier.Destroy;
begin
  FNagCounter.Free;
  inherited;
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSERTTKDeputyWizard.RegisterSplash;

end.
