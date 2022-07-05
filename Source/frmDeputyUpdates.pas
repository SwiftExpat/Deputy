unit frmDeputyUpdates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  SERTTK.DeputyTypes, SE.UpdateManager;

type
  TDeputyUpdates = class(TForm)
    gpUpdates: TGridPanel;
    lblHdrItem: TLabel;
    lblHdrVerCurr: TLabel;
    lblHdrUpdate: TLabel;
    memoMessages: TMemo;
    lblHdrVerAvail: TLabel;
    lblDeputy: TLabel;
    lblCaddie: TLabel;
    lblDemoFMX: TLabel;
    lblDemoVCL: TLabel;
    lblDeputyInst: TLabel;
    lblDeputyAvail: TLabel;
    btnUpdateDeputy: TButton;
    lblCaddieInst: TLabel;
    lblCaddieAvail: TLabel;
    btnUpdateCaddie: TButton;
    lblDemoFmxInst: TLabel;
    lblDemoFMXAvail: TLabel;
    btnUpdateDemoFMX: TButton;
    lblDemoVCLInst: TLabel;
    lblDemoVCLAvail: TLabel;
    btnUpdateDemoVCL: TButton;
    lblHdrUpdateRefresh: TLabel;
    lblUpdateRefresh: TLabel;
    procedure btnUpdateDemoFMXClick(Sender: TObject);
    procedure btnUpdateDemoVCLClick(Sender: TObject);
    procedure btnUpdateCaddieClick(Sender: TObject);
    procedure btnUpdateDeputyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDeputyUpdate: TSERTTKAppVersionUpdate;
    FUrlCacheMgr: TSEUrlCacheManager;
    FSettings: TSERTTKDeputySettings;
    FDeputyUtils: TSERTTKDeputyUtils;
    FMiCaddie, FMiDemoFMX, FMiDemoVCL: TMenuItem;
    procedure DownloadDoneCaddie(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
    procedure DownloadDoneDemoFMX(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
    procedure DownloadDoneDemoVCL(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
    procedure RefreshCaddie;
    procedure RefreshDemoFMX;
    procedure RefreshDemoVCL;
    procedure SaveCacheMgr;
    procedure OnVersionUpdateMessage(const AMessage: string);
    procedure LogMessage(AMessage: string);
    procedure UpdateLastRefresh;
    procedure OnDeputyVersionRefreshed(const AMessage: string);
  public
    procedure ExpertUpdatesRefresh;
    procedure AssignSettings(ASettings: TSERTTKDeputySettings);
    procedure AssignAppUpdate(const AAppUpdate: TSERTTKAppVersionUpdate);
    procedure AssignMenuItems(AMiCaddie, AMiDemoFMX, AMiDemoVCL: TMenuItem);
  end;

  EDeputyUpdatesCreate = class(Exception);

  TDeputyUpdatesFactory = class
  public
    class function DeputyUpdates: TDeputyUpdates;
    class function ShowDeputyUpdates: TDeputyUpdates;
    class procedure HideDeputyUpdates;
  end;

var
  DeputyUpdates: TDeputyUpdates;

implementation

{$R *.dfm}
{ TDeputyUpdates }

procedure TDeputyUpdates.AssignAppUpdate(const AAppUpdate: TSERTTKAppVersionUpdate);
begin
  FDeputyUpdate := AAppUpdate;
end;

procedure TDeputyUpdates.AssignMenuItems(AMiCaddie, AMiDemoFMX, AMiDemoVCL: TMenuItem);
begin
  FMiCaddie := AMiCaddie;
  FMiDemoFMX := AMiDemoFMX;
  FMiDemoVCL := AMiDemoVCL;
end;

procedure TDeputyUpdates.AssignSettings(ASettings: TSERTTKDeputySettings);
begin
  FSettings := ASettings;
end;

procedure TDeputyUpdates.btnUpdateCaddieClick(Sender: TObject);
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FDeputyUtils.url_caddie_download);
  if ce.CacheValid and FDeputyUtils.CaddieAppExists then
  begin
    FDeputyUtils.RunCaddie
  end
  else
    RefreshCaddie;
end;

procedure TDeputyUpdates.btnUpdateDemoFMXClick(Sender: TObject);
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FDeputyUtils.url_demo_fmx_download);
  if ce.CacheValid and FDeputyUtils.DemoFMXExists then
  begin
    FDeputyUtils.RunDemoFMX
  end
  else
    RefreshDemoFMX;
end;

procedure TDeputyUpdates.btnUpdateDemoVCLClick(Sender: TObject);
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FDeputyUtils.url_demo_vcl_download);
  if ce.CacheValid and FDeputyUtils.DemoVCLExists then
  begin
    FDeputyUtils.RunDemoVCL
  end
  else
    RefreshDemoVCL;
end;

procedure TDeputyUpdates.btnUpdateDeputyClick(Sender: TObject);
begin
  FDeputyUpdate.UpdateDeputyExpert
end;

procedure TDeputyUpdates.DownloadDoneCaddie(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
begin
  if FDeputyUtils.CaddieAppExists then
  begin
    FMiCaddie.Caption := 'Run Caddie';
    lblCaddieInst.Caption := ACacheEntry.LastModified;
  end;
  btnUpdateCaddie.Caption := 'Run Caddie or refresh';
  UpdateLastRefresh;
end;

procedure TDeputyUpdates.DownloadDoneDemoFMX(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
begin
  if FDeputyUtils.DemoFMXExists then
  begin
    FMiDemoFMX.Caption := 'Run Demo FMX';
    lblDemoFmxInst.Caption := ACacheEntry.LastModified;
  end;
  btnUpdateDemoFMX.Caption := 'Run Demo FMX or refresh';
  UpdateLastRefresh;
end;

procedure TDeputyUpdates.DownloadDoneDemoVCL(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
begin
  if FDeputyUtils.DemoVCLExists then
  begin
    FMiDemoVCL.Caption := 'Run DemoVCL';
    lblDemoVCLInst.Caption := ACacheEntry.LastModified;
  end;
  btnUpdateDemoVCL.Caption := 'Run Demo VCL or refresh';
  UpdateLastRefresh;
end;

procedure TDeputyUpdates.ExpertUpdatesRefresh;
begin
  FUrlCacheMgr.JsonString := FSettings.UrlCacheJson;
  FDeputyUpdate.OnMessage := OnVersionUpdateMessage;
  FDeputyUpdate.OnDeputyUpdatesRefreshed := OnDeputyVersionRefreshed;
  FDeputyUpdate.ExpertUpdatesRefresh();
  RefreshDemoFMX;
  RefreshDemoVCL;
  RefreshCaddie;
end;

procedure TDeputyUpdates.FormCreate(Sender: TObject);
begin
  FDeputyUtils := TSERTTKDeputyUtils.Create;
  FUrlCacheMgr := TSEUrlCacheManager.Create;
  FUrlCacheMgr.OnManagerMessage := LogMessage;
end;

procedure TDeputyUpdates.FormDestroy(Sender: TObject);
begin
  FUrlCacheMgr.Free;
  FDeputyUtils.Free;
end;

procedure TDeputyUpdates.LogMessage(AMessage: string);
var
  msg: string;
begin
  msg := 'Msg: ' + AMessage;
  TThread.Queue(nil,
    procedure
    begin
      memoMessages.Lines.Add(msg);
    end);
end;

procedure TDeputyUpdates.OnDeputyVersionRefreshed(const AMessage: string);
begin
  memoMessages.Lines.Add('deputy refreshed: ' + AMessage);
  lblDeputyInst.Caption := FDeputyUpdate.WizardVersion.VersionString;
  lblDeputyAvail.Caption := FDeputyUpdate.UpdateVersion.VersionString;
  btnUpdateDeputy.Enabled := FDeputyUpdate.ExpertUpdateAvailable;
  btnUpdateDeputy.Caption := FDeputyUpdate.UpdateExpertButtonText;
end;

procedure TDeputyUpdates.OnVersionUpdateMessage(const AMessage: string);
begin
  memoMessages.Lines.Add(AMessage)
end;

procedure TDeputyUpdates.RefreshCaddie;
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FDeputyUtils.url_caddie_download);
  ce.OnRefreshDone := DownloadDoneCaddie;
  ce.LocalPath := FDeputyUtils.CaddieDownloadFile;
  ce.ExtractPath := FDeputyUtils.RttkAppFolder;
  ce.ExtractZip := false;
  ce.OnRequestMessage := LogMessage;
  ce.RefreshCache;
end;

procedure TDeputyUpdates.RefreshDemoFMX;
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FDeputyUtils.url_demo_fmx_download);
  ce.OnRefreshDone := DownloadDoneDemoFMX;
  ce.LocalPath := FDeputyUtils.DemoDownloadFMXFile;
  ce.ExtractPath := FDeputyUtils.RttkAppFolder;
  ce.OnRequestMessage := LogMessage;
  ce.RefreshCache;
end;

procedure TDeputyUpdates.RefreshDemoVCL;
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FDeputyUtils.url_demo_vcl_download);
  ce.OnRefreshDone := DownloadDoneDemoVCL;
  ce.LocalPath := FDeputyUtils.DemoDownloadVCLFile;
  ce.ExtractPath := FDeputyUtils.RttkAppFolder;
  ce.OnRequestMessage := LogMessage;
  ce.RefreshCache;
end;

procedure TDeputyUpdates.SaveCacheMgr;
begin
  FSettings.UrlCacheJson := FUrlCacheMgr.JsonString;
end;

procedure TDeputyUpdates.UpdateLastRefresh;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      lblUpdateRefresh.Caption := FormatDateTime('mmm/dd/yyyy hh:nn:ss', now);
      SaveCacheMgr;
    end);
end;

{ TDeputyUpdatesFactory }

class function TDeputyUpdatesFactory.DeputyUpdates: TDeputyUpdates;
var
  i: integer;
begin
  for i := 0 to Screen.FormCount - 1 do // itterate the screens
    if Screen.Forms[i].ClassType = TDeputyUpdates then
    begin
      result := TDeputyUpdates(Screen.Forms[i]);
      if Screen.Forms[i].WindowState = TWindowState.wsMinimized then
        Screen.Forms[i].WindowState := TWindowState.wsNormal;
      exit;
    end;
  result := nil;
  try
    result := TDeputyUpdates.Create(Application);
  except // handle anything that does not let our form show up
    on E: Exception do
    begin
      if Assigned(result) then
        result.Free;
      raise EDeputyUpdatesCreate.Create('Create failed Deputy Updates form');
    end;
  end;
end;

class procedure TDeputyUpdatesFactory.HideDeputyUpdates;
begin
  DeputyUpdates.Hide;
end;

class function TDeputyUpdatesFactory.ShowDeputyUpdates: TDeputyUpdates;
begin
  result := DeputyUpdates;
  result.Show;
end;

end.
