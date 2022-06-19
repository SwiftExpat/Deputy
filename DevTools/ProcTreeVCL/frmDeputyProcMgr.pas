unit frmDeputyProcMgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SE.ProcMgrUtils;

type
  TDeputyProcMgr = class(TForm)
    memoLeak: TMemo;
    StatusBar1: TStatusBar;
    lbMgrParams: TListBox;
    lbMgrStatus: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FProcMgr: TSEProcessManager;
    FProcCleanup: TSEProcessCleanup;
    procedure LogMsg(AMessage: string);
    procedure LeakCopied(AMessage: string);
  public
    procedure AssignProcessCleanup(AProcCleanup: TSEProcessCleanup);
  end;

var
  DeputyProcMgr: TDeputyProcMgr;

implementation

{$R *.dfm}
{ TDeputyProcMgr }

procedure TDeputyProcMgr.AssignProcessCleanup(AProcCleanup: TSEProcessCleanup);
begin
  FProcCleanup := AProcCleanup;
  lbMgrParams.Items.Add('Process Name');
  lbMgrParams.Items.Add(FProcCleanup.ProcessName);

  lbMgrParams.Items.Add('Timeout');
  lbMgrParams.AddItem(FProcCleanup.Timeout.ToString, nil);
  lbMgrParams.Items.Add('Clean Proc Action');
  if FProcCleanup.StopCommand = TSEProcessStopCommand.tseProcStopKill then
    lbMgrParams.Items.Add('Terminate')
  else
    lbMgrParams.Items.Add('Close Window');
  lbMgrParams.Items.Add('MemLeak Action');
  if FProcCleanup.CloseMemLeak then
    lbMgrParams.Items.Add('Close Leak Window')
  else
    lbMgrParams.Items.Add('Leak Window Shown');
  FProcMgr.ProcessCleanup(FProcCleanup);
  memoLeak.Lines.Clear;
end;

procedure TDeputyProcMgr.FormCreate(Sender: TObject);
begin
  FProcMgr := TSEProcessManager.Create;
  FProcMgr.OnMessage := LogMsg;
  FProcMgr.OnLeakCopied := LeakCopied;
end;

procedure TDeputyProcMgr.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
end;

procedure TDeputyProcMgr.LeakCopied(AMessage: string);
begin
  memoLeak.Lines.Clear;
  PostMessage(memoLeak.Handle, WM_Paste, 0, 0);
  //copy leak to hist
end;

procedure TDeputyProcMgr.LogMsg(AMessage: string);
begin
  lbMgrStatus.Items.Add(AMessage);
end;

end.
