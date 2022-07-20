program ShowLeakMessage;

uses
  Vcl.Forms,
  frmShowMessageU in 'frmShowMessageU.pas' {Form1};

{$R *.res}

begin
  ReportMemoryLeaksonShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
