unit frmDeputyUpdates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SERTTK.DeputyTypes, SE.UpdateManager;

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
    FAppUpdate: TSERTTKAppVersionUpdate;
    FUrlCacheMgr: TSEUrlCacheManager;
    FSettings: TSERTTKDeputySettings;
    FDeputyUtils: TSERTTKDeputyUtils;
    procedure DownloadDoneCaddie(const AMessage: string);
    procedure DownloadDoneDemoFMX(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
    procedure DownloadDoneDemoVCL(const AMessage: string);
    procedure RefreshDemoFMX;
    procedure OnVersionUpdateMessage(const AMessage: string);
    procedure LogMessage(AMessage: string);
  public
    procedure ExpertUpdatesRefresh(const AAppUpdate: TSERTTKAppVersionUpdate);
    procedure AssignSettings(ASettings: TSERTTKDeputySettings);
  end;

  EDeputyUpdatesCreate = class(Exception);

  TDeputyUpdatesFactory = class
  public
    class function DeputyUpdates: TDeputyUpdates;
    class procedure ShowDeputyUpdates;
    class procedure HideDeputyUpdates;
  end;

var
  DeputyUpdates: TDeputyUpdates;

implementation

{$R *.dfm}
{ TDeputyUpdates }

procedure TDeputyUpdates.AssignSettings(ASettings: TSERTTKDeputySettings);
begin
  FSettings := ASettings;
end;

procedure TDeputyUpdates.btnUpdateCaddieClick(Sender: TObject);
begin
  FAppUpdate.DownloadCaddie;
end;

procedure TDeputyUpdates.btnUpdateDemoFMXClick(Sender: TObject);
begin
  FAppUpdate.DownloadDemoFMX;
end;

procedure TDeputyUpdates.btnUpdateDemoVCLClick(Sender: TObject);
begin
  FAppUpdate.DownloadDemoVCL;
end;

procedure TDeputyUpdates.btnUpdateDeputyClick(Sender: TObject);
begin
  FAppUpdate.UpdateDeputyExpert
end;

procedure TDeputyUpdates.DownloadDoneCaddie(const AMessage: string);
begin
  btnUpdateCaddie.Caption := 'Run Caddie';
  btnUpdateCaddie.OnClick := FAppUpdate.OnClickCaddieRun;
end;

procedure TDeputyUpdates.DownloadDoneDemoFMX(AMessage: string; ACacheEntry: TSEUrlCacheEntry);
begin
  if FDeputyUtils.DemoFMXExists then
  begin
  btnUpdateDemoFMX.Caption := 'Run Demo FMX';
  btnUpdateDemoFMX.OnClick := FAppUpdate.OnClickDemoFMX;
  lblDemoFmxInst.Caption :=  ACacheEntry.LastModified;
  end;

end;

procedure TDeputyUpdates.DownloadDoneDemoVCL(const AMessage: string);
begin

  btnUpdateDemoVCL.Caption := 'Run Demo VCL';
  btnUpdateDemoVCL.OnClick := FAppUpdate.OnClickDemoVCL;

end;

procedure TDeputyUpdates.ExpertUpdatesRefresh(const AAppUpdate: TSERTTKAppVersionUpdate);
begin
  FUrlCacheMgr.JsonString := FSettings.UrlCacheJson;
  FAppUpdate := AAppUpdate;
  FAppUpdate.OnMessage := OnVersionUpdateMessage;
  FAppUpdate.ExpertUpdatesRefresh();
  RefreshDemoFMX;
  FAppUpdate.OnDownloadDemoVCLDone := DownloadDoneDemoVCL;
  FAppUpdate.OnDownloadDemoVCLDone := DownloadDoneCaddie;
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

procedure TDeputyUpdates.OnVersionUpdateMessage(const AMessage: string);
begin
  memoMessages.Lines.Add(AMessage)
end;

procedure TDeputyUpdates.RefreshDemoFMX;
var
  ce: TSEUrlCacheEntry;
begin
  ce := FUrlCacheMgr.CacheByUrl(FAppUpdate.url_demo_downloads + FAppUpdate.dl_fl_demo_fmx);
  ce.OnRefreshDone := DownloadDoneDemoFMX;
  ce.LocalPath := FDeputyUtils.DemoDownloadFMXFile;
  ce.ExtractPath := FDeputyUtils.RttkAppFolder;
  ce.OnRequestMessage := LogMessage;
  ce.RefreshCache;
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

class procedure TDeputyUpdatesFactory.ShowDeputyUpdates;
begin
  DeputyUpdates.Show;
end;

end.
