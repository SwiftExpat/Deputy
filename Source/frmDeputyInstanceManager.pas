unit frmDeputyInstanceManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, SE.ProcMgrUtils;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // Version history
  // v1.0.0.0 : First Release

  { ******************************************************************** }
  { written by swiftexpat }
  { copyright 2022 }
  { Email : support@swiftexpat.com }
  { Web : https://swiftexpat.com }
  { }
  { The source code is given as is. The author is not responsible }
  { for any possible damage done due to the use of this code. }
  { The complete source code remains property of the author and may }
  { not be distributed, published, given or sold in any form as such. }
  { No parts of the source code can be included in any other component }
  { or application without written authorization of the author. }
  { ******************************************************************** }

type
  TDeputyInstanceManager = class(TForm)
    Label1: TLabel;
    btnCloseOriginal: TButton;
    btnCloseInstance: TButton;
    btnHideMessage: TButton;
    memoLog: TMemo;
    procedure btnHideMessageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseInstanceClick(Sender: TObject);
    procedure btnCloseOriginalClick(Sender: TObject);
  strict private
    FProcInfo, FDupInfo: TSEProcessInfo;
    FProcMgr: TSEProcessManager;
  private
    procedure LogMsg(AMessage: string);
    procedure LogInfo;
  public
    procedure CheckSecondInstance;
  end;

var
  DeputyInstanceManager: TDeputyInstanceManager;

implementation

{$R *.dfm}

procedure TDeputyInstanceManager.btnCloseInstanceClick(Sender: TObject);
begin
  Application.Terminate; // gracefully exit this instance of the IDE
end;

procedure TDeputyInstanceManager.btnCloseOriginalClick(Sender: TObject);
begin
  LogMsg('Terminating proc id :' + FDupInfo.ProcID.ToString);
  FProcMgr.TerminateProcessByID(FDupInfo.ProcID);
end;

procedure TDeputyInstanceManager.btnHideMessageClick(Sender: TObject);
begin
  self.Hide;
end;

procedure TDeputyInstanceManager.CheckSecondInstance;
begin
  try
    FProcInfo.ProcID := GetCurrentProcessID;
    if FProcMgr.ProcInfo(FProcInfo) then
    begin
      LogInfo;
      if FProcMgr.ProcessIsSecondInstance(FProcInfo, FDupInfo) then
      begin
        LogMsg('Second instance');
        self.Show;
      end
      else
        LogMsg('First instance');
    end
    else
      LogMsg('Could not get proc info');
  except
    on E: Exception do
      LogMsg('Exception:' + E.Message);
  end;
end;

procedure TDeputyInstanceManager.FormCreate(Sender: TObject);
begin
  FProcMgr := TSEProcessManager.Create;
  FProcInfo := TSEProcessInfo.Create;
  FDupInfo := TSEProcessInfo.Create;
  self.Caption := self.Caption + ' v'+Maj_Ver.ToString + '.'+Min_Ver.ToString + '.'+Rel_Ver.ToString;
end;

procedure TDeputyInstanceManager.FormDestroy(Sender: TObject);
begin
  FProcMgr.Free;
  FProcInfo.Free;
  FDupInfo.Free;
end;

procedure TDeputyInstanceManager.LogInfo;
begin
  LogMsg('ProcID = ' + FProcInfo.ProcID.ToString);
  LogMsg('ParentID = ' + FProcInfo.ParentProcID.ToString);
  LogMsg('ProcPath = ' + FProcInfo.ImagePath);
  LogMsg('Command Line' + FProcInfo.CommandLine);
end;

procedure TDeputyInstanceManager.LogMsg(AMessage: string);
begin
  memoLog.Lines.Add(AMessage);
end;

end.
