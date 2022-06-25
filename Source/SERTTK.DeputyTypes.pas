unit SERTTK.DeputyTypes;

interface

uses System.Classes, System.Win.Registry;

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
  public
    property KillProcActive: boolean read KillProcActiveGet write KillProcActiveSet;
    property LastUpdateCheck: TDateTime read LastUpdateCheckGet write LastUpdateCheckSet;
    property StopCommand: integer read StopCommandGet write StopCommandSet;
  end;

implementation

uses System.IOUtils, System.SysUtils, WinAPI.ShellAPI, WinAPI.Windows, System.DateUtils;

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

end.
