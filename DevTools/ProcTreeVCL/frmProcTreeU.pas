unit frmProcTreeU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Winapi.TlHelp32, SE.ProcMgrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
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
    procedure ProcessEval(AProcEntry: TProcessEntry32);
    procedure LogMsg(AMessage: string);
    function FullProcName:string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses System.IOUtils;

const
  DNLEN = 15;
  UNLEN = 256;

type
  PEnumInfo = ^TEnumInfo;

  TEnumInfo = record
    ProcessID: DWord;
    HWND: THandle;
  end;

{$R *.dfm}

procedure TForm1.btnCloseClick(Sender: TObject);
var
  lco: TSEProcessCleanup;
begin
  lco := TSEProcessCleanup.Create(FullProcName, TSEProcessStopCommand.tseProcStopClose);
  FProcMgr.ProcessCleanup(lco);

end;

procedure TForm1.btnKillClick(Sender: TObject);
var
  lco: TSEProcessCleanup;
begin
  lco := TSEProcessCleanup.Create(FullProcName, TSEProcessStopCommand.tseProcStopKill);
  FProcMgr.ProcessCleanup(lco);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
end;

function TForm1.FullProcName: string;
const
proc_dir = 'C:\Data\GitHub\SwiftExpat\RunTime-ToolKit\RunTime-ToolKit\Samples\vcl\Win32\Debug';
begin
result := TPath.Combine(proc_dir, edit1.Text);

end;

procedure TForm1.LogMsg(AMessage: string);
begin
  Memo1.Lines.Add(AMessage)
end;

procedure TForm1.ProcessEval(AProcEntry: TProcessEntry32);
var
  mw: DWord;
begin
  LogMsg(AProcEntry.th32ProcessID.ToString);
  mw := FProcMgr.FindMainWindow(AProcEntry.th32ProcessID);
  try
    LogMsg('Handle =' + mw.ToString);
    LogMsg('Handle =' + mw.ToHexString);
    PostMessage(mw, WM_CLOSE, 0, 0);
  except
    on E: EOSError do
      LogMsg('Error : ' + IntToStr(E.ErrorCode) + E.Message);
  end;

end;


end.
