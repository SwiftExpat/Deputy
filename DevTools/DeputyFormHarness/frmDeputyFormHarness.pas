unit frmDeputyFormHarness;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, SE.ProcMgrUtils, SERTTK.DeputyTypes, Vcl.Grids,
  Vcl.Samples.DirOutln, Vcl.FileCtrl, Vcl.ExtCtrls;

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
    tsIdeInstance: TTabSheet;
    GridPanel1: TGridPanel;
    lblIde1: TLabel;
    btnStartIde1: TButton;
    lblIde2: TLabel;
    btnStartIde2: TButton;
    lblPidIDE1: TLabel;
    lblPidIDE2: TLabel;
    editIde1Params: TEdit;
    editIde2Params: TEdit;
    procedure btnProcMgrShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bntProcTestClick(Sender: TObject);
    procedure btnSelectProcClick(Sender: TObject);
    procedure btnStartIde1Click(Sender: TObject);
    procedure btnStartIde2Click(Sender: TObject);

  private
    // FProcMgr: TSEProcessManager;
    FSettings: TSERTTKDeputySettings;
    FToolsDir : string;
    procedure SetToolsDir;
    procedure LogMsg(AMessage: string);
  public
    { Public declarations }
  end;

var
  frmDeputyHarness: TfrmDeputyHarness;

implementation

{$R *.dfm}

uses System.IOUtils, frmDeputyProcMgr, ShellAPI;

const
  proc_dir = 'C:\Repos\Github\Deputy\DevTools\LeakTests\Win32\Debug';
  proc_name = 'ShowLeakMessage.exe';
  ide_emulator = 'idebds.exe';
  ide_emulatordir = 'IDEEmulator\Win32\Debug';
  harness_dir = 'DeputyFormHarness\Win32\Debug';

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
  begin
    LogMsg('Change file to: '+OpenDialog1.FileName);
    valProcName.Caption := TPath.GetFileName(OpenDialog1.FileName);
    valDirName.Caption := TPath.GetDirectoryName(OpenDialog1.FileName);
  end
  else
    LogMsg('Abort File choose');
end;



procedure TfrmDeputyHarness.btnStartIde1Click(Sender: TObject);
var
  edir: string;
begin
  edir := TPath.Combine( FToolsDir, ide_emulatordir);
  //logMsg('edir= ' + Edir);
  ShellExecute(0, PChar('open'), PChar(AnsiQuotedStr(ide_emulator, Char(34))), PChar(editIde1Params.Text), PChar(eDir),
    SW_NORMAL);
end;

procedure TfrmDeputyHarness.btnStartIde2Click(Sender: TObject);
begin
  ShellExecute(0, PChar('open'), PChar(AnsiQuotedStr(ide_emulator, Char(34))), PChar(editIde2Params.Text), PChar( TPath.Combine( FToolsDir, ide_emulatordir)),
    SW_NORMAL);
end;

procedure TfrmDeputyHarness.FormCreate(Sender: TObject);
begin
  FSettings := TSERTTKDeputySettings.Create(TSERTTKDeputySettings.nm_settings_regkey);
  valProcName.Caption := proc_name;
  valDirName.Caption := proc_dir;
   SetToolsDir;
end;

procedure TfrmDeputyHarness.FormDestroy(Sender: TObject);
begin
  FSettings.free;
end;

procedure TfrmDeputyHarness.LogMsg(AMessage: string);
begin
  memoProcMgrMessage.Lines.Add(AMessage);
end;

procedure TfrmDeputyHarness.SetToolsDir;
var
  q1: integer;
  rl :string;
begin
  rl := cmdLine;
  q1 := rl.IndexOf('"');
  FToolsDir := rl.Substring((q1 + 1), rl.IndexOf('"', (q1 + 1)) - 1);
  FToolsDir := TPath.GetDirectoryName(FToolsDir).Replace(harness_dir, '');
  LogMsg('Tools dir = ' + FToolsDir);
end;

end.
