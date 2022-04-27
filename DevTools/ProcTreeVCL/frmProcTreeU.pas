unit frmProcTreeU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Winapi.TlHelp32, SE.ProcMgrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmProcTree = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    btnClose: TButton;
    Edit1: TEdit;
    btnKill: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
  private
    FProcMgr: TSEProcessManager;
    procedure LogMsg(AMessage: string);
    function FullProcName: string;
  public
    { Public declarations }
  end;

var
  frmProcTree: TfrmProcTree;

implementation

uses System.IOUtils;

{$R *.dfm}

procedure TfrmProcTree.btnCloseClick(Sender: TObject);
var
  lco: TSEProcessCleanup;
begin
  lco := TSEProcessCleanup.Create(FullProcName, TSEProcessStopCommand.tseProcStopClose);
  FProcMgr.ProcessCleanup(lco);

end;

procedure TfrmProcTree.btnKillClick(Sender: TObject);
var
  lco: TSEProcessCleanup;
begin
  lco := TSEProcessCleanup.Create(FullProcName, TSEProcessStopCommand.tseProcStopKill);
  FProcMgr.ProcessCleanup(lco);

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

function TfrmProcTree.FullProcName: string;
const
  proc_dir = 'C:\Data\GitHub\SwiftExpat\RunTime-ToolKit\RunTime-ToolKit\Samples\vcl\Win32\Debug';
begin
  result := TPath.Combine(proc_dir, Edit1.Text);

end;

procedure TfrmProcTree.LogMsg(AMessage: string);
begin
  Memo1.Lines.Add(AMessage)
end;

end.
