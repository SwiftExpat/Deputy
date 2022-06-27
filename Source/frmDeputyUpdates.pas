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
    bntUpdateDemoVCL: TButton;
  private
    FSettings: TSERTTKDeputySettings;
  public
    procedure ExpertUpdatesRefresh(const AWizardInfo: TSERTTKWizardInfo; const ASettings: TSERTTKDeputySettings);
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

procedure TDeputyUpdates.ExpertUpdatesRefresh(const AWizardInfo: TSERTTKWizardInfo;
  const ASettings: TSERTTKDeputySettings);
begin
  FSettings := ASettings;
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
