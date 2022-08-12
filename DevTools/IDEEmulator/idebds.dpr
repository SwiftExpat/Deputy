program idebds;

uses
  Vcl.Forms,
  frmIdeEmulator in 'frmIdeEmulator.pas' {frmIdeEmulate};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmIdeEmulate, frmIdeEmulate);
  Application.Run;
end.
