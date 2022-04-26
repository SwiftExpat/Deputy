program ProcTreeVCL;

uses
  Vcl.Forms,
  frmProcTreeU in 'frmProcTreeU.pas' {Form1},
  SE.ProcMgrUtils in '..\..\Source\SE.ProcMgrUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
