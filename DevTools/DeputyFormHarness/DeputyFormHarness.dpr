program DeputyFormHarness;

uses
  Vcl.Forms,
  frmDeputyFormHarness in 'frmDeputyFormHarness.pas' {frmDeputyHarness},
  frmDeputyProcMgr in '..\..\Source\frmDeputyProcMgr.pas' {DeputyProcMgr},
  SE.ProcMgrUtils in '..\..\Source\SE.ProcMgrUtils.pas',
  SERTTK.DeputyTypes in '..\..\Source\SERTTK.DeputyTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDeputyHarness, frmDeputyHarness);
  Application.Run;
end.
