unit frmDeputyFormHarness;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, SE.ProcMgrUtils, SERTTK.DeputyTypes, Vcl.Grids,
  Vcl.Samples.DirOutln, Vcl.FileCtrl;

type
  TfrmDeputyHarness = class(TForm)
    pcMain: TPageControl;
    tsProcMgr: TTabSheet;
    btnProcMgrShow: TButton;
    memoProcMgrMessage: TMemo;
    lblProcDir: TLabel;
    lblProcName: TLabel;
    bntProcTest: TButton;
    valDirName: TLabel;
    OpenDialog1: TOpenDialog;
    valProcName: TLabel;
    btnSelectProc: TButton;
    procedure btnProcMgrShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bntProcTestClick(Sender: TObject);
    procedure btnSelectProcClick(Sender: TObject);
  private
    // FProcMgr: TSEProcessManager;
    FSettings: TSERTTKDeputySettings;
    procedure LogMsg(AMessage: string);
  public
    { Public declarations }
  end;

var
  frmDeputyHarness: TfrmDeputyHarness;

implementation

{$R *.dfm}

uses System.IOUtils, frmDeputyProcMgr;

const
  proc_dir = 'C:\Repos\Github\Deputy\DevTools\LeakTests\Win32\Debug';
  proc_name = 'ShowLeakMessage.exe';

procedure TfrmDeputyHarness.bntProcTestClick(Sender: TObject);
var
  fmgr: TDeputyProcMgr;
  rslt: boolean;
begin
  fmgr := TDeputyProcMgrFactory.DeputyProcMgr;
  fmgr.AssignSettings(FSettings);
  rslt := fmgr.ClearProcess(valProcName.Caption, valDirName.Caption);
  if rslt then
    LogMsg('Process cleared')
  else
    LogMsg('Unable to clear Process')

end;

procedure TfrmDeputyHarness.btnProcMgrShowClick(Sender: TObject);
var
  fmgr: TDeputyProcMgr;
begin
  fmgr := TDeputyProcMgrFactory.DeputyProcMgr;
  fmgr.AssignSettings(FSettings);
  fmgr.Show;
end;

procedure TfrmDeputyHarness.btnSelectProcClick(Sender: TObject);
var
  rslt: boolean;
begin
OpenDialog1.InitialDir :=  valDirName.Caption;

  rslt := OpenDialog1.Execute;
  if rslt then
    LogMsg(OpenDialog1.FileName)
  else
    LogMsg('Abort File choose');
end;

procedure TfrmDeputyHarness.FormCreate(Sender: TObject);
begin
  FSettings := TSERTTKDeputySettings.Create(TSERTTKDeputySettings.nm_settings_regkey);
  valProcName.Caption := proc_name;
  valDirName.Caption := proc_dir;
end;

procedure TfrmDeputyHarness.FormDestroy(Sender: TObject);
begin
  FSettings.free;
end;

procedure TfrmDeputyHarness.LogMsg(AMessage: string);
begin
  memoProcMgrMessage.Lines.Add(AMessage);
end;

end.
