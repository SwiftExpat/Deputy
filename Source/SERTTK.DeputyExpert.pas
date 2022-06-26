unit SERTTK.DeputyExpert;

interface

implementation

uses System.Classes, ToolsAPI, VCL.Dialogs, System.SysUtils, System.TypInfo, Winapi.Windows, Winapi.TlHelp32,
  System.IOUtils, Generics.Collections, System.DateUtils, System.JSON,
  VCL.Forms, VCL.Menus, System.Win.Registry, ShellApi, VCL.Controls,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.ProjectManagerMenu,
  DW.OTA.Notifiers, SERTTK.DeputyTypes, SE.ProcMgrUtils;

type
  TSERTTKDeputyWizard = class;

  TSERTTKDeputyDebugNotifier = class(TDebuggerNotifier)
  private
    FWizard: TSERTTKDeputyWizard;
  strict private
    FProcMgr: TSEProcessManager;
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
    FProcMgr: TSEProcessManager;
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
      if FIDEStarted then //only message if the IDE is started, throws exception on show
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

procedure TSERTTKDeputyWizard.IDENotifierBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: boolean;
  var ACancel: boolean);
begin
  inherited;

end;

procedure TSERTTKDeputyWizard.IDEStarted;
begin
  inherited;

end;

procedure TSERTTKDeputyWizard.InitToolsMenu;
begin

end;


procedure TSERTTKDeputyWizard.MenuItemKillProcStatus;
begin

end;

procedure TSERTTKDeputyWizard.MessageCaddieCheck(const AMessage: string);
begin

end;

function TSERTTKDeputyWizard.NagCountReached: integer;
begin

end;

procedure TSERTTKDeputyWizard.OnClickMiKillProcEnabled(Sender: TObject);
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

end;

procedure TSERTTKDeputyDebugNotifier.CheckNagCount;
begin

end;

constructor TSERTTKDeputyDebugNotifier.Create(const AWizard: TSERTTKDeputyWizard);
begin

end;

destructor TSERTTKDeputyDebugNotifier.Destroy;
begin

  inherited;
end;

initialization

// Ensures that the add-in info is displayed on the IDE splash screen and About screen
TSERTTKDeputyWizard.RegisterSplash;

end.
