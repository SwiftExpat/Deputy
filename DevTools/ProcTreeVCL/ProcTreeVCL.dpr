program ProcTreeVCL;

uses
  Vcl.Forms,
  frmProcTreeU in 'frmProcTreeU.pas' {frmProcTree},
  SE.ProcMgrUtils in '..\..\Source\SE.ProcMgrUtils.pas',
  frmDeputyProcMgr in 'frmDeputyProcMgr.pas' {DeputyProcMgr},
  SERTTK.DeputyTypes in '..\..\Source\SERTTK.DeputyTypes.pas';

{$R *.res}

begin
  ReportMemoryLeaksonShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmProcTree, frmProcTree);
  Application.Run;
end.
