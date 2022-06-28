unit frmDeputyUpdates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SERTTK.DeputyTypes;

type
  TDeputyUpdates = class(TForm)
    gpUpdates: TGridPanel;
    lblHdrItem: TLabel;
    lblHdrVerCurr: TLabel;
    lblHdrUpdate: TLabel;
    Memo1: TMemo;
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
  private
    FAppUpdate: TSERTTKAppVersionUpdate;
    procedure DownloadDoneCaddie(const AMessage: string);
    procedure DownloadDoneDemoFMX(const AMessage: string);
    procedure DownloadDoneDemoVCL(const AMessage: string);
    procedure OnVersionUpdateMessage(const AMessage: string);
  public
    procedure ExpertUpdatesRefresh(const AAppUpdate: TSERTTKAppVersionUpdate);
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

procedure TDeputyUpdates.DownloadDoneDemoFMX(const AMessage: string);
begin
  btnUpdateDemoFMX.Caption := 'Run Demo FMX';
  btnUpdateDemoFMX.OnClick := FAppUpdate.OnClickDemoFMX;
end;

procedure TDeputyUpdates.DownloadDoneDemoVCL(const AMessage: string);
begin
  btnUpdateDemoVCL.Caption := 'Run Demo VCL';
  btnUpdateDemoVCL.OnClick := FAppUpdate.OnClickDemoVCL;
end;

procedure TDeputyUpdates.ExpertUpdatesRefresh(const AAppUpdate: TSERTTKAppVersionUpdate);
begin
  FAppUpdate := AAppUpdate;
  FAppUpdate.OnMessage := OnVersionUpdateMessage;
  FAppUpdate.ExpertUpdatesRefresh();
  FAppUpdate.OnDownloadDemoVCLDone := DownloadDoneDemoVCL;
  FAppUpdate.OnDownloadDemoFMXDone := DownloadDoneDemoFMX;
  FAppUpdate.OnDownloadDemoVCLDone := DownloadDoneCaddie;
end;

procedure TDeputyUpdates.OnVersionUpdateMessage(const AMessage: string);
begin
  Memo1.Lines.Add(AMessage)
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
