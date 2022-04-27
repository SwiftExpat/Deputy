program ProcTreeVCL;

uses
  Vcl.Forms,
  frmProcTreeU in 'frmProcTreeU.pas' {frmProcTree},
  SE.ProcMgrUtils in '..\..\Source\SE.ProcMgrUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmProcTree, frmProcTree);
  Application.Run;
end.
