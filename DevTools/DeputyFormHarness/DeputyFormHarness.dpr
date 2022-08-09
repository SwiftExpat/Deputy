program DeputyFormHarness;

uses
  Vcl.Forms,
  frmDeputyFormHarness in 'frmDeputyFormHarness.pas' {frmDeputyHarness};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDeputyHarness, frmDeputyHarness);
  Application.Run;
end.
