program ProcTreeVCL;

uses
  Vcl.Forms,
  frmProcTreeU in 'frmProcTreeU.pas' {frmProcTree},
  SE.ProcMgrUtils in '..\..\Source\SE.ProcMgrUtils.pas',
  SERTTK.DeputyTypes in '..\..\Source\SERTTK.DeputyTypes.pas',
  frmDeputyProcMgr in '..\..\Source\frmDeputyProcMgr.pas' {DeputyProcMgr};

{$R *.res}

begin
  ReportMemoryLeaksonShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmProcTree, frmProcTree);
  Application.Run;
end.
