unit SERTTK.DeputyExpert;

interface

const
  MAJ_VER = 2; // Major version nr.
  MIN_VER = 6; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.
  KASTRI_COMMIT = 'fa453cd';
  KASTRI_URL = 'https://github.com/DelphiWorlds/Kastri/commit/fa453cd2afaa47739f01133a5f22cf4dc391fc84';
  TOTAL_COMMIT = '2ec8360';
  TOTAL_URL = 'https://github.com/DelphiWorlds/TOTAL/commit/2ec8360328bab72b0ade817f1ffd168210f2098e';

  { Built with TOTAL & KASTRI versions:
    KASTRI : fa453cd : https://github.com/DelphiWorlds/Kastri/commit/fa453cd2afaa47739f01133a5f22cf4dc391fc84
    TOTAL : 2ec8360 : https://github.com/DelphiWorlds/TOTAL/commit/2ec8360328bab72b0ade817f1ffd168210f2098e
  }

  // Version history
  // v1.1.1.0 : First Release
  // v2.5.0.0 : This version implments forms to display progress
  // v2.5.1.0 : New Nag counter
  // v2.5.3.0 : Version release GPL
  // v2.6.1.0 : Instance manager and options screens

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

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections, System.DateUtils, System.JSON, frmDeputyProcMgr, frmDeputyUpdates,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, SERTTK.DeputyTypes, SE.ProcMgrUtils, frmDeputyInstanceManager, frmDeputyOptionsInstance,
  frmDeputyOptInstanceManager, frmDeputyOptProcessManager, frmDeputyOptUpdates;

type

  TSERTTKDeputyWizard = class;

  TSERTTKDeputyDebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSERTTKDeputyWizard;
  public
    function BeforeProgramLaunch(const Project: IOTAProject): boolean; override;
    constructor Create(const AWizard: TSERTTKDeputyWizard);
    destructor Destroy; override;
  end;

  TSERTTKDeputyWizard = class(TIDENotifierOTAWizard)
  const
    nag_interval = 10;
    nm_tools_menu = 'SE Deputy';
    nm_tools_menuitem = 'miSEDeputyRoot';
    nm_message_group = 'SE Deputy';
    nm_mi_procmgr = 'procmgritem';
    nm_mi_run_caddie = 'caddierunitem';
    nm_mi_run_vcldemo = 'demovclrunitem';
    nm_mi_run_fmxdemo = 'demofmxrunitem';
    nm_mi_show_website = 'showwebsiteitem';
    nm_mi_update_status = 'updatestatusitem';
    nm_mi_show_options = 'showoptionsitem';
    nm_wizard_id = 'com.swiftexpat.deputy';
    nm_wizard_display = 'RunTime ToolKit - Deputy';
  strict private
    FIDEStarted: boolean;
    FProcMgrForm: TDeputyProcMgr;
    FDeputyUpdates: TDeputyUpdates;
    FToolsMenuRootItem: TMenuItem;
    FSettings: TSERTTKDeputySettings;
    FInstanceManager: TDeputyInstanceManager;
    FRTTKAppUpdate: TSERTTKAppVersionUpdate;
    FWizardInfo: TSERTTKWizardInfo;
    FMenuItems: TDictionary<string, TMenuItem>;
    FNagCounter: TSERTTKNagCounter;
    FDeputyUtils: TSERTTKDeputyUtils;
    FIdeOptions, FInstMgrOptions, FProcMgrOptions, FUpdateOptions: INTAAddInOptions;
    function MenuItemByName(const AItemName: string): TMenuItem;
    procedure OnClickDeputyUpdates(Sender: TObject);
    procedure OnClickMiProcessManager(Sender: TObject);
  private
    FDebugNotifier: ITOTALNotifier;
    procedure InitToolsMenu;
    procedure AssignUpdateMenuItems;
    function FindMenuItemFirstLine(const AMenuItem: TMenuItem): integer;
    procedure MessagesAdd(const AMessage: string);
    procedure OnClickShowWebsite(Sender: TObject);
    procedure OnClickShowOptions(Sender: TObject);
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
{$IF COMPILERVERSION > 32}
  TOTAHelper.RegisterThemeForms([TDeputyUpdates, TDeputyProcMgr, TDeputyInstanceManager]);
{$ENDIF}
  FMenuItems := TDictionary<string, TMenuItem>.Create;
  FDebugNotifier := TSERTTKDeputyDebugNotifier.Create(self);
  FRTTKAppUpdate := TSERTTKAppVersionUpdate.Create;
  FNagCounter := TSERTTKNagCounter.Create(0, 7);
  FSettings := TSERTTKDeputySettings.Create(TSERTTKDeputySettings.nm_settings_regkey);
  InitToolsMenu;
  // options main menu
  FIdeOptions := TSERTTKDeputyIDEOptionsInterface.Create;
  TSERTTKDeputyIDEOptionsInterface(FIdeOptions).DeputySettings := FSettings;
  (BorlandIDEServices As INTAEnvironmentOptionsServices).RegisterAddInOptions(FIdeOptions);
  // options instance manager
  FInstMgrOptions := TSERTTKDeputyIDEOptInstMgr.Create;
  TSERTTKDeputyIDEOptInstMgr(FInstMgrOptions).DeputySettings := FSettings;
  (BorlandIDEServices As INTAEnvironmentOptionsServices).RegisterAddInOptions(FInstMgrOptions);
  // options process manager
  FProcMgrOptions := TSERTTKDeputyIDEOptProcMgr.Create;
  TSERTTKDeputyIDEOptProcMgr(FProcMgrOptions).DeputySettings := FSettings;
  (BorlandIDEServices As INTAEnvironmentOptionsServices).RegisterAddInOptions(FProcMgrOptions);
  // options Updates
  // FUpdateOptions := TSERTTKDeputyIDEOptUpdates.Create;
  // TSERTTKDeputyIDEOptUpdates(FUpdateOptions).DeputySettings := FSettings;
  // (BorlandIDEServices As INTAEnvironmentOptionsServices).RegisterAddInOptions(FUpdateOptions);
end;

destructor TSERTTKDeputyWizard.Destroy;
begin
  FDebugNotifier.RemoveNotifier;
  // (BorlandIDEServices As INTAEnvironmentOptionsServices).UnregisterAddInOptions(FUpdateOptions);
  FUpdateOptions := nil;
  (BorlandIDEServices As INTAEnvironmentOptionsServices).UnregisterAddInOptions(FProcMgrOptions);
  FProcMgrOptions := nil;
  (BorlandIDEServices As INTAEnvironmentOptionsServices).UnregisterAddInOptions(FInstMgrOptions);
  FInstMgrOptions := nil;
  (BorlandIDEServices As INTAEnvironmentOptionsServices).UnregisterAddInOptions(FIdeOptions);
  FIdeOptions := nil;
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
{$IF COMPILERVERSION > 32}
  TOTAHelper.ApplyTheme(FProcMgrForm);
{$ENDIF}
  FProcMgrForm.AssignSettings(FSettings);
  FDeputyUpdates := TDeputyUpdatesFactory.DeputyUpdates;
  TOTAHelper.ApplyTheme(FDeputyUpdates);
  FDeputyUpdates.AssignSettings(FSettings);
  FDeputyUpdates.AssignAppUpdate(FRTTKAppUpdate);
  AssignUpdateMenuItems;
  if FSettings.DetectSecondInstance then
  begin
    FInstanceManager := TDeputyInstanceManager.Create(Application);
    TOTAHelper.ApplyTheme(FInstanceManager);
    FInstanceManager.CheckSecondInstance;
  end;
  FDeputyUpdates.ExpertUpdatesRefresh(false);
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
  mi := MenuItemByName(nm_mi_procmgr);
  mi.OnClick := OnClickMiProcessManager;
  mi.Caption := 'Process Manager';
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_show_options);
  mi.Caption := 'Deputy Options';
  mi.OnClick := OnClickShowOptions;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_update_status);
  mi.Caption := 'Deputy Updates';
  mi.OnClick := OnClickDeputyUpdates;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_show_website);
  mi.Caption := 'RTTK Website';
  mi.OnClick := OnClickShowWebsite;
  FToolsMenuRootItem.Add(mi);
  mic := MenuItemByName(nm_mi_run_caddie);
  mic.Caption := 'Refreshing Caddie';
  FToolsMenuRootItem.Add(mic);
  miv := MenuItemByName(nm_mi_run_vcldemo);
  miv.Caption := 'Refreshing Demo VCL';
  FToolsMenuRootItem.Add(miv);
  mif := MenuItemByName(nm_mi_run_fmxdemo);
  mif.Caption := 'Refreshing Demo FMX';
  FToolsMenuRootItem.Add(mif);
end;

procedure TSERTTKDeputyWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
  var ACancel: boolean);
begin
  TOTAHelper.ClearMessageGroup(nm_message_group);
  if FSettings.KillProcActive and (AIsCodeInsight = false) then
  begin
    ACancel := FProcMgrForm.CompileContinue(AProject.ProjectOptions.TargetName);
{$IFDEF GITHUBEVAL}
    if FNagCounter.NagUser then
    begin
      FNagCounter.NagLess(nag_interval);
      MessagesAdd('Please evaluate RunTime ToolKit, https://swiftexpat.com')
    end;
{$ENDIF}
  end;
  inherited;
end;

procedure TSERTTKDeputyWizard.OnClickDeputyUpdates(Sender: TObject);
begin
  FDeputyUpdates.ExpertUpdatesRefresh(false);
  FDeputyUpdates.Show;
end;

procedure TSERTTKDeputyWizard.OnClickMiProcessManager(Sender: TObject);
begin
   FProcMgrForm.ShowManager;
end;

procedure TSERTTKDeputyWizard.OnClickShowOptions(Sender: TObject);
begin
  (BorlandIDEServices As IOTAServices).GetEnvironmentOptions.EditOptions('', caption_options_label);
end;

procedure TSERTTKDeputyWizard.OnClickShowWebsite(Sender: TObject);
begin
  FDeputyUtils.ShowWebsite;
end;

{ TSERTTKDeputyDebugNotifier }

function TSERTTKDeputyDebugNotifier.BeforeProgramLaunch(const Project: IOTAProject): boolean;
begin
  if FWizard.Settings.KillProcActive then
  begin
    result := FWizard.ProcMgrForm.DebugLaunch(Project.ProjectOptions.TargetName);
  end
  else
    result := true;
end;

constructor TSERTTKDeputyDebugNotifier.Create(const AWizard: TSERTTKDeputyWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

destructor TSERTTKDeputyDebugNotifier.Destroy;
begin
  inherited;
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSERTTKDeputyWizard.RegisterSplash;

end.
