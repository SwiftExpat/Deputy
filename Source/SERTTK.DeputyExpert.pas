unit SERTTK.DeputyExpert;

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections, System.DateUtils, System.JSON, frmDeputyProcMgr,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, SERTTK.DeputyTypes, SE.ProcMgrUtils;

type
  TSERTTKDeputyWizard = class;

  TSERTTKDeputyDebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSERTTKDeputyWizard;
  strict private
    //FProcMgr: TSEProcessManager;
    FNagCounter: TSERTTKNagCounter;
    procedure CheckNagCount;
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
    FToolsMenuRootItem: TMenuItem;
    FSettings: TSERTTKDeputySettings;
    FRTTKAppUpdate: TSERTTKAppVersionUpdate;
    FWizardInfo: TSERTTKWizardInfo;
    FMenuItems: TDictionary<string, TMenuItem>;
    FNagCounter: TSERTTKNagCounter;
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
    property Settings: TSERTTKDeputySettings read FSettings;
    procedure IDEStarted; override;
    function NagCountReached: integer;
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
  FProcMgrForm := TDeputyProcMgrFactory.DeputyProcMgr;
  FProcMgrForm.AssignSettings(FSettings);
  // FRTTKAppUpdate.ExpertUpdatesRefresh(FWizardInfo, FSettings);
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

procedure TSERTTKDeputyWizard.MessagesAdd(const AMessageList: TStringList);
var
  s: string;
begin
  for s in AMessageList do
    MessagesAdd(s)
end;
{$ENDREGION}

procedure TSERTTKDeputyWizard.InitToolsMenu;
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
  mi.Caption := FRTTKAppUpdate.ButtonTextCaddie;
  mi.OnClick := FRTTKAppUpdate.OnClickCaddieRun;
  FRTTKAppUpdate.OnMessage := MessageCaddieCheck;
  FRTTKAppUpdate.OnDownloadDone := CaddieCheckDownloaded;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_show_website);
  mi.Caption := 'RTTK Website';
  mi.OnClick := FRTTKAppUpdate.OnClickShowWebsite;
  FToolsMenuRootItem.Add(mi);

  mi := MenuItemByName(nm_mi_run_vcldemo);
  mi.Caption := FRTTKAppUpdate.ButtonTextDemoVCL;
  mi.OnClick := FRTTKAppUpdate.OnClickDemoVCL;
  FRTTKAppUpdate.OnDownloadDemoVCLDone := DemoVCLDownloaded;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_run_fmxdemo);
  mi.Caption := FRTTKAppUpdate.ButtonTextDemoFMX;
  mi.OnClick := FRTTKAppUpdate.OnClickDemoFMX;
  FRTTKAppUpdate.OnDownloadDemoFMXDone := DemoFMXDownloaded;
  FToolsMenuRootItem.Add(mi);
  mi := MenuItemByName(nm_mi_update_status);
  mi.Caption := 'Loading Version'; // FRTTKCheck.UpdateExpertButtonText;
  // FRTTKAppUpdate.ExpertUpdateMenuItem := mi;
  FToolsMenuRootItem.Add(mi);

end;

procedure TSERTTKDeputyWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
  var ACancel: boolean);
begin
  TOTAHelper.ClearMessageGroup(nm_message_group);
{$IFDEF DEBUG}
  MessagesAdd('Before Compile');
{$ENDIF}
  if FSettings.KillProcActive and (AIsCodeInsight = false) then
  begin
    ACancel := FProcMgrForm.CompileContinue(AProject.ProjectOptions.TargetName);
{$IFDEF GITHUBEVAL}
    if FNagCounter.NagUser then
      FNagCounter.NagLess(NagCountReached);
{$ENDIF}
  end;
  inherited;

end;

procedure TSERTTKDeputyWizard.MenuItemKillProcStatus;
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

procedure TSERTTKDeputyWizard.OnClickMiKillProcEnabled(Sender: TObject);
begin
  FProcMgrForm.ShowSettings;
end;

procedure TSERTTKDeputyWizard.MessageCaddieCheck(const AMessage: string);
begin

end;

function TSERTTKDeputyWizard.NagCountReached: integer;
begin

end;

procedure TSERTTKDeputyWizard.DemoFMXDownloaded(const AMessage: string);
begin

end;

procedure TSERTTKDeputyWizard.DemoVCLDownloaded(const AMessage: string);
begin

end;

procedure TSERTTKDeputyWizard.CaddieCheckDownloaded(const AMessage: string);
begin

end;

{ TSERTTKDeputyDebugNotifier }

function TSERTTKDeputyDebugNotifier.BeforeProgramLaunch(const Project: IOTAProject): boolean;
begin
  CheckNagCount;
{$IFDEF DEBUG}
  FWizard.MessagesAdd('Before Program Launch');
{$ENDIF}
  if FWizard.Settings.KillProcActive then
  begin
     result := FWizard.ProcMgrForm.ClearProcess(Project.ProjectOptions.TargetName);
    // FWizard.MessagesAdd(FProcMgr.Actions);
  end
  else
    result := true;
end;

procedure TSERTTKDeputyDebugNotifier.CheckNagCount;
begin
{$IFDEF GITHUBEVAL}
  if FNagCounter.NagUser then
    FNagCounter.NagLess(FWizard.NagCountReached);
{$ENDIF}
end;

constructor TSERTTKDeputyDebugNotifier.Create(const AWizard: TSERTTKDeputyWizard);
begin
  inherited Create;
  FWizard := AWizard;
  // FProcMgr := TSEIAProcessManagerUtil.Create;
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
