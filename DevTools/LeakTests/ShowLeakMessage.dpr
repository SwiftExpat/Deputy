program ShowLeakMessage;

uses
  Vcl.Forms,
  frmShowMessageU in 'frmShowMessageU.pas' {LeakLoopTester};

{$R *.res}

begin
  ReportMemoryLeaksonShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TLeakLoopTester, LeakLoopTester);
  Application.Run;
end.
