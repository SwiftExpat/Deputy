unit frmProcTreeU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Winapi.TlHelp32, SE.ProcMgrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

const
  proc_dir = 'C:\Data\GitHub\SwiftExpat\RunTime-ToolKit\RunTime-ToolKit\Samples\fmx\Win32\Release';

type
  TfrmProcTree = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    btnClose: TButton;
    Edit1: TEdit;
    btnKill: TButton;
    btnForm: TButton;
    btnFunction: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure btnFormClick(Sender: TObject);
    procedure btnFunctionClick(Sender: TObject);
  private
    FProcMgr: TSEProcessManager;
    procedure LogMsg(AMessage: string);
    function ProcName: string;
  public
    { Public declarations }
  end;

var
  frmProcTree: TfrmProcTree;

implementation

uses System.IOUtils, frmDeputyProcMgr;

{$R *.dfm}

procedure TfrmProcTree.btnCloseClick(Sender: TObject);
var
  lco: TSEProcessCleanup;
begin
  lco := TSEProcessCleanup.Create(ProcName, proc_dir, TSEProcessStopCommand.tseProcStopClose);
  //FProcMgr.ProcessCleanup(lco);
  PostMessage(Memo1.Handle, WM_Paste, 0, 0);
end;

procedure TfrmProcTree.btnFormClick(Sender: TObject);
var
  fmgr: TDeputyProcMgr;
begin
  fmgr := TDeputyProcMgrFactory.DeputyProcMgr;
  fmgr.Show;
  fmgr.CleanProcess(ProcName, proc_dir, TSEProcessStopCommand.tseProcStopClose);
end;

procedure TfrmProcTree.btnFunctionClick(Sender: TObject);
var
  fmgr: TDeputyProcMgr;
  rslt : boolean;
begin
  fmgr := TDeputyProcMgrFactory.DeputyProcMgr;
//  fmgr.Show;
  rslt := fmgr.ClearProcess(ProcName, proc_dir, TSEProcessStopCommand.tseProcStopClose);
  if rslt  then
  memo1.Lines.Add('Process cleared')
  else
  memo1.Lines.Add('Unable to clear Process')


end;

procedure TfrmProcTree.btnKillClick(Sender: TObject);
var
  fmgr: TDeputyProcMgr;
begin
  fmgr := TDeputyProcMgrFactory.DeputyProcMgr;
  fmgr.Show;
end;

procedure TfrmProcTree.FormCreate(Sender: TObject);
begin
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
end;

procedure TfrmProcTree.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
end;

function TfrmProcTree.ProcName: string;
begin
  result := Edit1.Text;

end;

procedure TfrmProcTree.LogMsg(AMessage: string);
begin
  Memo1.Lines.Add(AMessage)
end;

end.
