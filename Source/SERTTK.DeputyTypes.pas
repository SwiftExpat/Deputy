unit SERTTK.DeputyTypes;

interface

uses System.Classes, System.SysUtils, System.Win.Registry, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.URLClient;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // Version history
  // v1.1.1.0 : First Release

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

type
  TSERTTKDeputyUtils = class
  const
    dl_fl_name = 'SERTTK_Caddie_dl.zip';
    dl_fl_demo_vcl = 'RTTK_Demo_VCL.zip';
    dl_fl_demo_fmx = 'RTTK_Demo_FMX.zip';
    nm_user_agent = 'Deputy Expert';
    fl_nm_demo_vcl = 'RTTK.VCL.exe';
    fl_nm_demo_fmx = 'RTTK_FMX.exe';
    fl_nm_deputy_version = 'DeputyVersion.xml';
    fl_nm_deputy_expert_zip = 'DeputyExpert.zip';
    fl_nm_pre_deputy_expert_zip = 'DeputyLicensed_';
    fl_nm_suf_deputy_expert_zip = '.zip';
    rk_nm_expert = 'SwiftExpat Deputy';
    nm_json_object = 'DeputyVersion';
    url_domain = '.swiftexpat.com';
    url_demos = 'https://demos' + url_domain;
{$IFDEF UPDATEDEV}
    url_lic = 'https://devupdates' + url_domain;
{$ELSE}
    url_lic = 'https://licadmin' + url_domain;
{$ENDIF}
    url_website = 'https://' + url_domain;
    url_demo_downloads = url_demos + '/downloads/';
    url_deputyrttk = url_lic + '/deputyrttk/';
    url_deputy_version = url_deputyrttk + fl_nm_deputy_version;
  public
    /// <summary>
    /// Returns  C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit\RT_Caddie.exe
    /// </summary>
    /// <remarks>
    /// uses RttkAppFolder C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit
    /// </remarks>
    function CaddieAppFile: string;
    /// <summary>
    /// Returns C:\Users\%USERNAME%\AppData\Roaming\RTTK\Downloads\ SERTTK_Caddie_dl.zip
    /// </summary>
    /// <remarks>
    /// TPath.Combine(RttkDownloadDirectory, dl_fl_name);
    /// </remarks>
    function CaddieDownloadFile: string;
    function CaddieAppExists: boolean;
    /// <summary>
    /// returns C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit\RTTK_FMX.exe
    /// </summary>
    /// <remarks>
    /// TPath.Combine(RttkAppFolder, fl_nm_demo_fmx)
    /// </remarks>
    function DemoAppFMXFile: string;
    /// <summary>
    /// returns C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit\RTTK.VCL.exe
    /// </summary>
    /// <remarks>
    /// TPath.Combine(RttkAppFolder, fl_nm_demo_vcl)
    /// </remarks>
    function DemoAppVCLFile: string;
    /// <remarks>
    /// TPath.Combine(RttkDownloadDirectory, dl_fl_demo_fmx)
    /// </remarks>
    function DemoDownloadFMXFile: string;
    /// <remarks>
    /// TPath.Combine(RttkDownloadDirectory, dl_fl_demo_vcl)
    /// </remarks>
    function DemoDownloadVCLFile: string;
    function DemoFMXExists: boolean;
    function DemoVCLExists: boolean;
    function DeputyExpertZipFile(const AVersion: string = ''): string;
    function DeputyExpertDownloadFile: string;
    function DeputyExpertVersionName(const AVersion: string = ''): string;
    /// <summary>
    /// Returns  C:\Users\%USERNAME%\AppData\Local\Programs\RunTime_ToolKit
    /// </summary>
    /// <remarks>
    /// uses TPath.GetCachePath for C:\Users\Coder\AppData\Local
    /// </remarks>
    function RttkAppFolder: string;
    /// <summary>
    /// Returns C:\Users\%USERNAME%\AppData\Roaming\RTTK
    /// </summary>
    /// <remarks>
    /// uses GetHomePath for  C:\Users\%USERNAME%\AppData\Roaming
    /// </remarks>
    function RttkDataDirectory: string;
    /// <summary>
    /// Returns C:\Users\%USERNAME%\AppData\Roaming\RTTK\Downloads
    /// </summary>
    /// <remarks>
    /// uses RttkDataDirectory for C:\Users\%USERNAME%\AppData\Roaming\RTTK
    /// </remarks>
    function RttkDownloadDirectory: string;
    /// <summary>
    /// Returns C:\Users\%USERNAME%\AppData\Roaming\RTTK\Updates
    /// </summary>
    /// <remarks>
    /// uses RttkDataDirectory for C:\Users\%USERNAME%\AppData\Roaming\RTTK
    /// </remarks>
    function RttkUpdatesDirectory: string;
    /// <summary>
    /// returns C:\Users\%USERNAME%\AppData\Roaming\RTTK\RTTKCaddie.ini
    /// </summary>
    /// <remarks>
    /// uses RttkDataDirectory for C:\Users\%USERNAME%\AppData\Roaming\RTTK
    /// </remarks>
    function CaddieIniFile: string;
    function CaddieIniFileExists: boolean;
    /// <summary>
    /// returns C:\Users\Coder\AppData\Roaming\RTTK\Downloads\DeputyManifest.xml
    /// </summary>
    function DeputyVersionDownloadFile: string;
    /// <summary>
    /// returns C:\Users\Coder\AppData\Roaming\RTTK\Updates\DeputyManifest.xml
    /// </summary>
    function DeputyVersionFile: string;
    function DeputyVersionFileExists: boolean;
    /// <summary>
    /// returns C:\Users\%USERNAME%\AppData\Roaming\RTTK\Updates\Deputy
    /// </summary>
    /// <param name="AVersion">
    /// Appends AVersion if supplied, creates directory if not exists
    /// </param>
    /// <remarks>
    /// TPath.Combine(RttkUpdatesDirectory, 'Deputy')
    /// </remarks>
    function DeputyWizardUpdatesDirectory(const AVersion: string = ''): string;
    procedure ShowWebsite;
    procedure RunCaddie;
    procedure RunDemoVCL;
    procedure RunDemoFMX;
    property Downloaded: boolean read CaddieAppExists;
    property Executed: boolean read CaddieIniFileExists;
  end;

  TSERTTKDeputySettings = class(TRegistryIniFile)
  const
    nm_section_updates = 'Updates';
    nm_updates_lastupdate = 'LastUpdateCheckDate';
    nm_section_killprocess = 'KillProcess';
    nm_killprocess_enabled = 'Enabled';
    nm_killprocess_closeleak = 'CloseLeakWindow';
    nm_killprocess_copyleak = 'CopyLeakWindow';
    nm_killprocess_stopcommand = 'StopCommand';
    nm_settings_regkey = 'SOFTWARE\SwiftExpat\Deputy';
  strict private
    function KillProcActiveGet: boolean;
    procedure KillProcActiveSet(const Value: boolean);
    function LastUpdateCheckGet: TDateTime;
    procedure LastUpdateCheckSet(const Value: TDateTime);
  private
    function StopCommandGet: integer;
    procedure StopCommandSet(const Value: integer);
    function CloseLeakWindowGet: boolean;
    procedure CloseLeakWindowSet(const Value: boolean);
    function CopyLeakMessageGet: boolean;
    procedure CopyLeakMessageSet(const Value: boolean);
  public
    property KillProcActive: boolean read KillProcActiveGet write KillProcActiveSet;
    property LastUpdateCheck: TDateTime read LastUpdateCheckGet write LastUpdateCheckSet;
    property StopCommand: integer read StopCommandGet write StopCommandSet;
    property CloseLeakWindow: boolean read CloseLeakWindowGet write CloseLeakWindowSet;
    property CopyLeakMessage: boolean read CopyLeakMessageGet write CopyLeakMessageSet;
  end;

  TSERTTKNagCounter = class
  strict private
    FNagCount, FNagLevel: integer;
  public
    constructor Create(const ANagCount: integer = 0; const ANagLevel: integer = 5);
    function NagUser: boolean;
    procedure NagLess(ANagCount: integer);
  end;

  TSERTTKVersionInfo = class
  public
    VerMaj: integer;
    VerMin: integer;
    VerRel: integer;
    function VersionString: string;
  end;

  TSERTTKWizardInfo = class
  public
    WizardFileName: string; // make this a dynamic call to reflect the rename
    WizardVersion: string;
    function AgentString: string;
  end;

  TSECaddieCheckOnMessage = procedure(const AMessage: string) of object;
  TSECaddieCheckOnDownloadDone = procedure(const AMessage: string) of object;

  TSERTTKAppVersionUpdate = class
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
    FDeputyUtils: TSERTTKDeputyUtils;
    FLicensed: boolean;
    FSettings: TSERTTKDeputySettings;
    FWizardInfo: TSERTTKWizardInfo;
    FWizardVersion, FUpdateVersion: TSERTTKVersionInfo;
    FHTTPReqCaddie, FHTTPReqDemoFMX, FHTTPReqDemoVCL, FHTTPReqDeputyVersion, FHTTPReqDeputyDL: TNetHTTPRequest;
    FHTTPClient: TNetHTTPClient;
    FOnMessage: TSECaddieCheckOnMessage;
    FOnDownloadDone, FOnDownloadFMXDemoDone, FOnDownloadVCLDemoDone: TSECaddieCheckOnDownloadDone;
    procedure LogMessage(AMessage: string);
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
    procedure HttpClientException(const Sender: TObject; const AError: Exception);
    procedure HttpDeputyExpertDownload;
    procedure HttpDeputyVersionDownload;
    procedure HttpDeputyDLException(const Sender: TObject; const AError: Exception);
    procedure HttpDeputyDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure HttpDeputyVersionException(const Sender: TObject; const AError: Exception);
    procedure HttpDeputyVersionCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure ExpertLogUsage(const AUsageStep: string);
  private
    // FExpertUpdateMenuItem: TMenuItem;
    // function ExpertFileLocation: string;
    function ExpertUpdateAvailable: boolean;
    function ExpertUpdateDownloaded: boolean;
    // procedure ExpertUpdateMenuItemSet(const Value: TMenuItem);
    procedure LoadDeputyUpdateVersion;
    procedure OnClickUpdateExpert(Sender: TObject);
    function UpdateExpertButtonText: string;
  public
    procedure DownloadCaddie;
    constructor Create;
    destructor Destroy; override;
    // property Downloaded: boolean read CaddieAppExists;
    // property Executed: boolean read CaddieIniFileExists;
    // property Licensed: boolean read FLicensed write FLicensed;
    function ButtonTextCaddie: string;
    function ButtonTextDemoVCL: string;
    function ButtonTextDemoFMX: string;
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
    procedure ExpertUpdatesRefresh(const AWizardInfo: TSERTTKWizardInfo; const ASettings: TSERTTKDeputySettings);
    // property ExpertUpdateMenuItem: TMenuItem read FExpertUpdateMenuItem write ExpertUpdateMenuItemSet;
  end;

implementation

uses System.IOUtils, WinAPI.ShellAPI, WinAPI.Windows, System.DateUtils, System.Zip, System.JSON;

{ TSERTTKDeputyUtils }

function TSERTTKDeputyUtils.CaddieAppExists: boolean;
begin
  result := TFile.Exists(CaddieAppFile);
end;

function TSERTTKDeputyUtils.CaddieAppFile: string;
begin
  result := TPath.Combine(RttkAppFolder, 'RT_Caddie.exe')
end;

function TSERTTKDeputyUtils.CaddieDownloadFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, dl_fl_name);
end;

function TSERTTKDeputyUtils.CaddieIniFile: string;
begin
  result := TPath.Combine(RttkDataDirectory, 'RTTKCaddie.ini');
end;

function TSERTTKDeputyUtils.CaddieIniFileExists: boolean;
begin
  result := TFile.Exists(CaddieIniFile)
end;

function TSERTTKDeputyUtils.DemoAppFMXFile: string;
begin
  result := TPath.Combine(RttkAppFolder, fl_nm_demo_fmx)
end;

function TSERTTKDeputyUtils.DemoAppVCLFile: string;
begin
  result := TPath.Combine(RttkAppFolder, fl_nm_demo_vcl)
end;

function TSERTTKDeputyUtils.DemoDownloadFMXFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, dl_fl_demo_fmx)
end;

function TSERTTKDeputyUtils.DemoDownloadVCLFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, dl_fl_demo_vcl)
end;

function TSERTTKDeputyUtils.DemoFMXExists: boolean;
begin
  result := TFile.Exists(DemoAppFMXFile)
end;

function TSERTTKDeputyUtils.DemoVCLExists: boolean;
begin
  result := TFile.Exists(DemoAppVCLFile)
end;

function TSERTTKDeputyUtils.DeputyExpertDownloadFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, fl_nm_deputy_expert_zip)
end;

function TSERTTKDeputyUtils.DeputyExpertVersionName(const AVersion: string): string;
begin
  result := fl_nm_pre_deputy_expert_zip + AVersion + fl_nm_suf_deputy_expert_zip;
end;

function TSERTTKDeputyUtils.DeputyExpertZipFile(const AVersion: string = ''): string;
begin
  result := TPath.Combine(DeputyWizardUpdatesDirectory, DeputyExpertVersionName(AVersion));
end;

function TSERTTKDeputyUtils.DeputyVersionDownloadFile: string;
begin
  result := TPath.Combine(RttkDownloadDirectory, fl_nm_deputy_version)
end;

function TSERTTKDeputyUtils.DeputyVersionFile: string;
begin
  result := TPath.Combine(RttkUpdatesDirectory, fl_nm_deputy_version)
end;

function TSERTTKDeputyUtils.DeputyVersionFileExists: boolean;
begin
  result := TFile.Exists(DeputyVersionFile);
end;

function TSERTTKDeputyUtils.DeputyWizardUpdatesDirectory(const AVersion: string = ''): string;
begin
  result := TPath.Combine(RttkUpdatesDirectory, 'Deputy');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
  if not AVersion.IsEmpty then
    result := TPath.Combine(result, AVersion);
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

function TSERTTKDeputyUtils.RttkAppFolder: string;
begin
  result := TPath.Combine(TPath.GetCachePath, 'Programs\RunTime_ToolKit');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

function TSERTTKDeputyUtils.RttkDataDirectory: string;
begin
  result := TPath.Combine(TPath.GetHomePath, 'RTTK');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result)
end;

function TSERTTKDeputyUtils.RttkDownloadDirectory: string;
begin
  result := TPath.Combine(RttkDataDirectory, 'Downloads');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

function TSERTTKDeputyUtils.RttkUpdatesDirectory: string;
begin
  result := TPath.Combine(RttkDataDirectory, 'Updates');
  if not TDirectory.Exists(result) then
    TDirectory.CreateDirectory(result);
end;

procedure TSERTTKDeputyUtils.RunCaddie;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(CaddieAppFile);
  shi.lpDirectory := PChar(RttkAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
end;

procedure TSERTTKDeputyUtils.RunDemoFMX;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(DemoAppFMXFile);
  shi.lpDirectory := PChar(RttkAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
end;

procedure TSERTTKDeputyUtils.RunDemoVCL;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(DemoAppVCLFile);
  shi.lpDirectory := PChar(RttkAppFolder);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
end;

procedure TSERTTKDeputyUtils.ShowWebsite;
var
  shi: TShellExecuteInfo;
begin
  shi := Default (TShellExecuteInfo);
  shi.lpVerb := PChar('open');
  shi.cbSize := SizeOf(TShellExecuteInfo);
  shi.lpFile := PChar(url_website);
  shi.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@shi);
end;

{ TSERTTKDeputySettings }

function TSERTTKDeputySettings.CloseLeakWindowGet: boolean;
begin
  result := self.ReadBool(nm_section_killprocess, nm_killprocess_closeleak, true);
end;

procedure TSERTTKDeputySettings.CloseLeakWindowSet(const Value: boolean);
begin
  self.WriteBool(nm_section_killprocess, nm_killprocess_closeleak, Value);
end;

function TSERTTKDeputySettings.CopyLeakMessageGet: boolean;
begin
  result := self.ReadBool(nm_section_killprocess, nm_killprocess_copyleak, true);
end;

procedure TSERTTKDeputySettings.CopyLeakMessageSet(const Value: boolean);
begin
  self.WriteBool(nm_section_killprocess, nm_killprocess_copyleak, Value);
end;

function TSERTTKDeputySettings.KillProcActiveGet: boolean;
begin
  result := self.ReadBool(nm_section_killprocess, nm_killprocess_enabled, true);
end;

procedure TSERTTKDeputySettings.KillProcActiveSet(const Value: boolean);
begin
  self.WriteBool(nm_section_killprocess, nm_killprocess_enabled, Value);
end;

function TSERTTKDeputySettings.LastUpdateCheckGet: TDateTime;
begin
  result := self.ReadDateTime(nm_section_updates, nm_updates_lastupdate, IncDay(now, -1))
end;

procedure TSERTTKDeputySettings.LastUpdateCheckSet(const Value: TDateTime);
begin
  self.WriteDateTime(nm_section_updates, nm_updates_lastupdate, Value);
end;

function TSERTTKDeputySettings.StopCommandGet: integer;
begin
  result := self.ReadInteger(nm_section_killprocess, nm_killprocess_stopcommand, 0)
end;

procedure TSERTTKDeputySettings.StopCommandSet(const Value: integer);
begin
  self.WriteInteger(nm_section_killprocess, nm_killprocess_stopcommand, Value);
end;

{ TSERTTKNagCounter }

constructor TSERTTKNagCounter.Create(const ANagCount, ANagLevel: integer);
begin
  FNagCount := ANagCount;
  FNagLevel := ANagLevel;
end;

procedure TSERTTKNagCounter.NagLess(ANagCount: integer);
begin
  FNagCount := ANagCount;
end;

function TSERTTKNagCounter.NagUser: boolean;
begin
{$IFDEF GITHUBEVAL}
  inc(FNagCount);
{$ENDIF}
  result := FNagLevel = FNagCount;
  if result then
    FNagCount := 0;
end;

{ TSERTTKVersionInfo }

function TSERTTKVersionInfo.VersionString: string;
begin
  result := VerMaj.ToString + '.' + VerMin.ToString + '.' + VerRel.ToString;
end;

{ TSERTTKWizardInfo }

function TSERTTKWizardInfo.AgentString: string;
begin
  result := 'Ver=' + WizardVersion;
  result := result + ' Platform=' + TPath.GetFileName(WizardFileName)
end;

{ TSERTTKAppVersionUpdate }

function TSERTTKAppVersionUpdate.ButtonTextCaddie: string;
begin
  if FDeputyUtils.CaddieAppExists then
    result := 'Run Caddie'
  else
    result := 'Download & Install Caddie'
end;

function TSERTTKAppVersionUpdate.ButtonTextDemoFMX: string;
begin
  if FDeputyUtils.DemoFMXExists then
    result := 'Run FMX Demo'
  else
    result := 'Download & Install FMX Demo'
end;

function TSERTTKAppVersionUpdate.ButtonTextDemoVCL: string;
begin
  if FDeputyUtils.DemoVCLExists then
    result := 'Run VCL Demo'
  else
    result := 'Download & Install VCL Demo'
end;

constructor TSERTTKAppVersionUpdate.Create;
begin
  FLicensed := false;
  FDeputyUtils := TSERTTKDeputyUtils.Create;
end;

destructor TSERTTKAppVersionUpdate.Destroy;
begin
  FHTTPReqCaddie.Free;
  FHTTPReqDemoFMX.Free;
  FHTTPReqDemoVCL.Free;
  FHTTPClient.Free;
  FDeputyUtils.Free;
  inherited;
end;

procedure TSERTTKAppVersionUpdate.DistServerAuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType;
  const ARealm, AURL: string; var AUserName, APassword: string; var AbortAuth: boolean;
  var Persistence: TAuthPersistenceType);
begin
  if AnAuthTarget = TAuthTargetType.Server then
  begin
    AUserName := 'DeputyExpert';
    APassword := 'Illbeyourhuckleberry';
  end;
end;

procedure TSERTTKAppVersionUpdate.DownloadCaddie;
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

procedure TSERTTKAppVersionUpdate.DownloadDemoFMX;
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
  FHTTPReqDemoFMX.Get(url_demo_downloads + dl_fl_demo_fmx);
end;

procedure TSERTTKAppVersionUpdate.DownloadDemoVCL;
begin
  InitHttpClient;
  if not Assigned(FHTTPReqDemoVCL) then
    FHTTPReqDemoVCL := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDemoVCL.OnRequestException := HttpDemoVCLDLException;
  FHTTPReqDemoVCL.SynchronizeEvents := false;
{$ELSE}
  FHTTPReqCaddie.OnRequestError := HttpCaddieDLException;
  FHTTPReqDemoVCL.Asynchronous := true;
{$ENDIF}
  FHTTPReqDemoVCL.Client := FHTTPClient;
  FHTTPReqDemoVCL.OnRequestCompleted := HttpDemoVCLDLCompleted;
  FHTTPReqDemoVCL.Asynchronous := true;
  FHTTPReqDemoVCL.Get(url_demo_downloads + dl_fl_demo_vcl);
end;

procedure TSERTTKAppVersionUpdate.ExpertLogUsage(const AUsageStep: string);
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

function TSERTTKAppVersionUpdate.ExpertUpdateAvailable: boolean;
begin
  if not Assigned(FWizardVersion) and not Assigned(FUpdateVersion) then
    exit(false); // should raise exception?

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

function TSERTTKAppVersionUpdate.ExpertUpdateDownloaded: boolean;
begin
  result := true; // fix this
end;

procedure TSERTTKAppVersionUpdate.ExpertUpdatesRefresh(const AWizardInfo: TSERTTKWizardInfo;
  const ASettings: TSERTTKDeputySettings);
begin
  FSettings := ASettings;
  FWizardInfo := AWizardInfo;
  ExpertLogUsage('Refresh-Updates');

  if Assigned(FWizardVersion) then
    FWizardVersion.Free;

  FWizardVersion := TSERTTKVersionInfo.Create;
  FWizardVersion.VerMaj := AWizardInfo.WizardVersion.Split(['.'])[0].ToInteger;
  FWizardVersion.VerMin := AWizardInfo.WizardVersion.Split(['.'])[1].ToInteger;
  FWizardVersion.VerRel := AWizardInfo.WizardVersion.Split(['.'])[2].ToInteger;
  // check the settings for last update dts
  if (HoursBetween(FSettings.LastUpdateCheck, now) < 8) and FDeputyUtils.DeputyVersionFileExists then
  begin
    LogMessage('Using cached values');
    LoadDeputyUpdateVersion;
    // FExpertUpdateMenuItem.Caption := UpdateExpertButtonText;
  end
  else
  begin // async download must update button after checking the file
    LogMessage('Checking server for updates');
    HttpDeputyVersionDownload;
  end;
end;

procedure TSERTTKAppVersionUpdate.HttpCaddieDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(FDeputyUtils.CaddieDownloadFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting');
    if TZipFile.IsValid(FDeputyUtils.CaddieDownloadFile) then
    begin
      LogMessage('Zip File is valid');
      TZipFile.ExtractZipFile(FDeputyUtils.CaddieDownloadFile, FDeputyUtils.RttkAppFolder);
      if TFile.Exists(FDeputyUtils.CaddieAppFile) then
      begin
        FDeputyUtils.RunCaddie;
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

procedure TSERTTKAppVersionUpdate.HttpCaddieDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Caddie~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKAppVersionUpdate.HttpClientException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Http Client Deputy Expert~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKAppVersionUpdate.HttpDemoFMXDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
const
  nm_log_id = 'Demo FMX';
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(FDeputyUtils.DemoDownloadFMXFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting ' + nm_log_id);
    if TZipFile.IsValid(FDeputyUtils.DemoDownloadFMXFile) then
    begin
      LogMessage('Zip File is valid ' + FDeputyUtils.DemoDownloadFMXFile);
      TZipFile.ExtractZipFile(FDeputyUtils.DemoDownloadFMXFile, FDeputyUtils.RttkAppFolder);
      if TFile.Exists(FDeputyUtils.DemoAppFMXFile) then
      begin
        FDeputyUtils.RunDemoFMX;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnDownloadDemoFMXDone) then
              OnDownloadDemoFMXDone('Downloaded ' + nm_log_id);
          end);
      end
      else // for file exists
        LogMessage(nm_log_id + ' not found after extract. ' + FDeputyUtils.DemoAppFMXFile);
    end
    else // Zip file invalid
      LogMessage('Zip File not valid ' + FDeputyUtils.DemoDownloadFMXFile)
  end
  else
    LogMessage('Download ' + nm_log_id + ' Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKAppVersionUpdate.HttpDemoFMXDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Demo FMX~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKAppVersionUpdate.HttpDemoVCLDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
const
  nm_log_id = 'Demo VCL';
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(FDeputyUtils.DemoDownloadVCLFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting ' + nm_log_id);
    if TZipFile.IsValid(FDeputyUtils.DemoDownloadVCLFile) then
    begin
      LogMessage('Zip File is valid ' + FDeputyUtils.DemoDownloadVCLFile);
      TZipFile.ExtractZipFile(FDeputyUtils.DemoDownloadVCLFile, FDeputyUtils.RttkAppFolder);
      if TFile.Exists(FDeputyUtils.DemoAppVCLFile) then
      begin
        FDeputyUtils.RunDemoVCL;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnDownloadDemoVCLDone) then
              OnDownloadDemoVCLDone('Downloaded ' + nm_log_id);
          end);
      end
      else // for file exists
        LogMessage(nm_log_id + ' not found after extract. ' + FDeputyUtils.DemoAppVCLFile);
    end
    else // Zip file invalid
      LogMessage('Zip File not valid ' + FDeputyUtils.DemoDownloadVCLFile)
  end
  else
    LogMessage('Download ' + nm_log_id + ' Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKAppVersionUpdate.HttpDemoVCLDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Demo VCL~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKAppVersionUpdate.HttpDeputyDLCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(FDeputyUtils.DeputyExpertDownloadFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Complete, Extracting Deputy Experts');
    if TZipFile.IsValid(FDeputyUtils.DeputyExpertDownloadFile) then
    begin
      LogMessage('Zip File is valid ' + FDeputyUtils.DeputyExpertDownloadFile);
      TZipFile.ExtractZipFile(FDeputyUtils.DeputyExpertDownloadFile, FDeputyUtils.DeputyWizardUpdatesDirectory);
      LogMessage('Wizard Updates Extracted.');
    end
    else // Zip file invalid
      LogMessage('Zip File not valid ' + FDeputyUtils.DeputyExpertDownloadFile)
  end
  else
    LogMessage('Download Deputy Expert Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKAppVersionUpdate.HttpDeputyDLException(const Sender: TObject; const AError: Exception);
var
  msg: string;
begin
  msg := 'Download Deputy Expert~Server Exception:' + AError.Message;
  LogMessage(msg);
end;

procedure TSERTTKAppVersionUpdate.HttpDeputyExpertDownload;
begin
  InitHttpClient;
  if not Assigned(FHTTPReqDeputyVersion) then
    FHTTPReqDeputyVersion := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDeputyVersion.OnRequestException := HttpDeputyDLException;
  FHTTPReqDeputyVersion.SynchronizeEvents := false;
{$ELSE}
  FHTTPReqDeputyVersion.Asynchronous := true;
{$ENDIF}
  FHTTPReqDeputyVersion.Client := FHTTPClient;
  FHTTPReqDeputyVersion.OnRequestCompleted := HttpDeputyDLCompleted;
  FHTTPReqDeputyVersion.Asynchronous := true;
  FHTTPReqDeputyVersion.Get(url_demo_downloads + fl_nm_deputy_expert_zip);
end;

procedure TSERTTKAppVersionUpdate.HttpDeputyVersionCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
      var
  lfs: TFileStream;
begin
  if AResponse.StatusCode = 200 then
  begin
    lfs := TFileStream.Create(FDeputyUtils.DeputyVersionFile, fmCreate);
    lfs.CopyFrom(AResponse.ContentStream, 0);
    lfs.Free;
    LogMessage('Download Version Complete, Loading');

    TThread.Queue(nil,
      procedure
      begin
        LoadDeputyUpdateVersion;
        //FExpertUpdateMenuItem.Caption := UpdateExpertButtonText;
        if ExpertUpdateAvailable and not ExpertUpdateDownloaded then
          HttpDeputyExpertDownload;
        FSettings.LastUpdateCheck := now;
      end);
  end
  else
    LogMessage('Download Deputy Version Http result = ' + AResponse.StatusCode.ToString);
end;

procedure TSERTTKAppVersionUpdate.HttpDeputyVersionDownload;
begin
     InitHttpClient;
  if not Assigned(FHTTPReqDeputyVersion) then
    FHTTPReqDeputyVersion := TNetHTTPRequest.Create(nil);
{$IF COMPILERVERSION > 33}
  FHTTPReqDeputyVersion.OnRequestException := HttpDeputyVersionException;
  FHTTPReqDeputyVersion.SynchronizeEvents := false;
{$ELSE}
  FHTTPReqDeputyVersion.OnRequestError :=
  FHTTPReqDeputyVersion.Asynchronous := true;
{$ENDIF}
  FHTTPReqDeputyVersion.Client := FHTTPClient;
  FHTTPReqDeputyVersion.OnRequestCompleted := HttpDeputyVersionCompleted;
  FHTTPReqDeputyVersion.Asynchronous := true;
  FHTTPReqDeputyVersion.Get(url_version + fl_nm_deputy_version);
end;

procedure TSERTTKAppVersionUpdate.HttpDeputyVersionException(const Sender: TObject; const AError: Exception);
begin

end;

procedure TSERTTKAppVersionUpdate.InitHttpClient;
begin
  if not Assigned(FHTTPClient) then
  begin
    FHTTPClient := TNetHTTPClient.Create(nil);
    FHTTPClient.OnAuthEvent := DistServerAuthEvent;
{$IF COMPILERVERSION > 33}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
    FHTTPClient.OnRequestException := HttpClientException;
    FHTTPClient.UseDefaultCredentials := false;
{$ELSEIF COMPILERVERSION = 33}
    FHTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
{$ENDIF}
    FHTTPClient.UserAgent := nm_user_agent + ' ' + FWizardInfo.AgentString;
    { TODO : Create a hash of Username / Computer name }
  end;
end;

procedure TSERTTKAppVersionUpdate.LoadDeputyUpdateVersion;
var
  JSONValue: TJSONValue;
begin
  if not Assigned(FUpdateVersion) then
    FUpdateVersion := TSERTTKVersionInfo.Create;
  FUpdateVersion.VerMaj := -1;
  FUpdateVersion.VerMin := -1;
  FUpdateVersion.VerRel := -1;
  if not FDeputyUtils.DeputyVersionFileExists then
    exit;
  JSONValue := TJSONObject.ParseJSONValue(TFile.ReadAllText(FDeputyUtils.DeputyVersionFile));

  if JSONValue is TJSONObject then
  begin
    FUpdateVersion.VerMaj := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_major);
    FUpdateVersion.VerMin := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_minor);
    FUpdateVersion.VerRel := JSONValue.GetValue<integer>(nm_json_object + '.' + nm_json_prop_release);
  end;
end;

procedure TSERTTKAppVersionUpdate.LogMessage(AMessage: string);
var
  msg: string;
begin
  msg := 'Msg RTTK_App_Update: ' + AMessage;
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FOnMessage) then
        FOnMessage(msg);
    end);
end;

procedure TSERTTKAppVersionUpdate.OnClickCaddieRun(Sender: TObject);
begin
  if FDeputyUtils.CaddieAppExists then
    FDeputyUtils.RunCaddie
  else
    DownloadCaddie;
end;

procedure TSERTTKAppVersionUpdate.OnClickDemoFMX(Sender: TObject);
begin
  if FDeputyUtils.DemoFMXExists then
    FDeputyUtils.RunDemoFMX
  else
    DownloadDemoFMX;
end;

procedure TSERTTKAppVersionUpdate.OnClickDemoVCL(Sender: TObject);
begin
  if FDeputyUtils.DemoVCLExists then
    FDeputyUtils.RunDemoVCL
  else
    DownloadDemoVCL;
end;

procedure TSERTTKAppVersionUpdate.OnClickShowWebsite(Sender: TObject);
begin
  FDeputyUtils.ShowWebsite;
end;

procedure TSERTTKAppVersionUpdate.OnClickUpdateExpert(Sender: TObject);
var
  fn: string;
begin  // rename dll FWizardInfo.WizardFileName
//  try
//    if not SameText(ExpertFileLocation, FWizardInfo.WizardFileName) then
//    begin // ensure the Update would be for the wizard loaded
//      FExpertUpdateMenuItem.Caption := 'Dll missmatch to registry';
//      exit;
//    end;
//    if FWizardInfo.WizardFileName = DeputyWizardBackupFilename then
//    begin // pending restart, do not continue
//      FExpertUpdateMenuItem.Caption := 'Restart IDE to load update';
//      exit;
//    end;
    fn := TPath.GetFileName(FWizardInfo.WizardFileName);
//    if not TFile.Exists(DeputyWizardUpdateFilename(fn)) then
//    begin // no update to install, exit
//      FExpertUpdateMenuItem.Caption := 'Update not found';
//      exit;
//    end;
//    if TFile.Exists(DeputyWizardBackupFilename) then
//      TFile.Delete(DeputyWizardBackupFilename);
//    TFile.Move(FWizardInfo.WizardFileName, DeputyWizardBackupFilename);
//    TFile.Move(DeputyWizardUpdateFilename(fn), ExpertFileLocation);
//  except
//    on E: Exception do
//    begin // likely IO related
//      FExpertUpdateMenuItem.Caption := 'E:' + E.Message.Substring(0, 20);
//      LogMessage('Failed Update ' + E.Message);
//    end;
//  end;
//
//  FExpertUpdateMenuItem.Caption := 'Restart IDE pending';

end;

function TSERTTKAppVersionUpdate.UpdateExpertButtonText: string;
begin
     if ExpertUpdateAvailable then
    result := 'Update Available to  ' + FUpdateVersion.VersionString
  else
    result := 'Version is current ' + FWizardVersion.VersionString;
end;

end.
