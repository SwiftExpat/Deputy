unit frmDeputyOptProcessManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsAPI, SERTTK.DeputyTypes, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Samples.Spin, SE.ProcMgrUtils;

const
  caption_opt_label_proc_mgr = 'Deputy.Process Manager';
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
  TfrmDeputyOptProcMgr = class(TFrame)
    llHeader: TLinkLabel;
    rgProcMgrActive: TRadioGroup;
    rgProcStopCommand: TRadioGroup;
    cbCloseLeakWindow: TCheckBox;
    cbCopyLeakMessage: TCheckBox;
    gpTimeouts: TGridPanel;
    lblHdrTimeouts: TLabel;
    lblWaitPollTimeout: TLabel;
    edtWaitPoll: TSpinEdit;
    lblHdrShowDelay: TLabel;
    edtShowDelay: TSpinEdit;
    gpOptions: TGridPanel;
    memoMessage: TMemo;
    gpMainLayout: TGridPanel;
    procedure rgProcMgrActiveClick(Sender: TObject);
    procedure rgProcStopCommandClick(Sender: TObject);
    procedure cbCloseLeakWindowClick(Sender: TObject);
    procedure cbCopyLeakMessageClick(Sender: TObject);
    procedure edtWaitPollChange(Sender: TObject);
    procedure edtShowDelayChange(Sender: TObject);
  strict private
    FSettings: TSERTTKDeputySettings;
    FStopCommand: TSEProcessStopCommand;
    procedure UpdateSettings;
  public
    property DeputySettings: TSERTTKDeputySettings read FSettings write FSettings;
    procedure InitializeFrame;
    procedure FinalizeFrame;
  end;

  TSERTTKDeputyIDEOptProcMgr = Class(TInterfacedObject, INTAAddInOptions)
  Strict Private
    FFrame: TfrmDeputyOptProcMgr;
    FSettings: TSERTTKDeputySettings;
  Public
    property DeputySettings: TSERTTKDeputySettings read FSettings write FSettings;
    Procedure DialogClosed(Accepted: Boolean);
    Procedure FrameCreated(AFrame: TCustomFrame);
    Function GetArea: String;
    Function GetCaption: String;
    Function GetFrameClass: TCustomFrameClass;
    Function GetHelpContext: Integer;
    Function IncludeInIDEInsight: Boolean;
    Function ValidateContents: Boolean;
  End;

implementation

{$R *.dfm}
{ TfrmDeputyOptProcMgr }

procedure TfrmDeputyOptProcMgr.cbCloseLeakWindowClick(Sender: TObject);
begin
  if cbCloseLeakWindow.Checked then
    FSettings.CloseLeakWindow := true
  else
    FSettings.CloseLeakWindow := false;
  UpdateSettings;
end;

procedure TfrmDeputyOptProcMgr.cbCopyLeakMessageClick(Sender: TObject);
begin
  if cbCopyLeakMessage.Checked then
    FSettings.CopyLeakMessage := true
  else
    FSettings.CopyLeakMessage := false;
  UpdateSettings;
end;

procedure TfrmDeputyOptProcMgr.edtShowDelayChange(Sender: TObject);
begin
  if (edtShowDelay.Value > edtShowDelay.MinValue) and (edtShowDelay.Value < edtShowDelay.MaxValue) then
    FSettings.ShowWindowDelay := edtShowDelay.Value;
end;

procedure TfrmDeputyOptProcMgr.edtWaitPollChange(Sender: TObject);
begin
  if (edtWaitPoll.Value > edtWaitPoll.MinValue) and (edtWaitPoll.Value < edtWaitPoll.MaxValue) then
    FSettings.WaitPollInterval := edtWaitPoll.Value;
end;

procedure TfrmDeputyOptProcMgr.FinalizeFrame;
begin

end;

procedure TfrmDeputyOptProcMgr.InitializeFrame;
begin
  if assigned(FSettings) then
  begin
    UpdateSettings;
    edtWaitPoll.Value := FSettings.WaitPollInterval;
    edtShowDelay.Value := FSettings.ShowWindowDelay;
    rgProcMgrActive.OnClick := rgProcMgrActiveClick;
    rgProcStopCommand.OnClick := rgProcStopCommandClick;
    cbCloseLeakWindow.OnClick := cbCloseLeakWindowClick;
    cbCopyLeakMessage.OnClick := cbCopyLeakMessageClick;
  end;

end;

procedure TfrmDeputyOptProcMgr.rgProcStopCommandClick(Sender: TObject);
begin
  FSettings.StopCommand := rgProcStopCommand.ItemIndex;
  UpdateSettings;
end;

procedure TfrmDeputyOptProcMgr.rgProcMgrActiveClick(Sender: TObject);
begin
  if rgProcMgrActive.ItemIndex = 0 then
    FSettings.KillProcActive := false
  else
    FSettings.KillProcActive := true;
  UpdateSettings;
end;

procedure TfrmDeputyOptProcMgr.UpdateSettings;
begin
  if FSettings.KillProcActive then
  begin
    rgProcMgrActive.ItemIndex := 1;
    rgProcStopCommand.ItemIndex := FSettings.StopCommand;
    FStopCommand := TSEProcessStopCommand(FSettings.StopCommand);
    rgProcStopCommand.Visible := true;
    case FStopCommand of
      tseProcStopKill:
        begin
          cbCloseLeakWindow.Visible := false;
          cbCopyLeakMessage.Visible := false;
        end;
      tseProcStopClose:
        begin
          cbCloseLeakWindow.Checked := FSettings.CloseLeakWindow;
          cbCopyLeakMessage.Checked := FSettings.CopyLeakMessage;
          cbCloseLeakWindow.Visible := true;
          cbCopyLeakMessage.Visible := cbCloseLeakWindow.Checked;
        end;
    end;
  end
  else
  begin
    rgProcMgrActive.ItemIndex := 0;
    rgProcStopCommand.Visible := false;
    cbCloseLeakWindow.Visible := false;
    cbCopyLeakMessage.Visible := false;
  end;
end;

{ TSERTTKDeputyIDEOptProcMgr }

procedure TSERTTKDeputyIDEOptProcMgr.DialogClosed(Accepted: Boolean);
begin
  if Accepted then
    FFrame.FinalizeFrame;
end;

procedure TSERTTKDeputyIDEOptProcMgr.FrameCreated(AFrame: TCustomFrame);
begin
  If AFrame Is TfrmDeputyOptProcMgr Then
  Begin
    FFrame := AFrame As TfrmDeputyOptProcMgr;
    FFrame.DeputySettings := DeputySettings;
    FFrame.InitializeFrame;
  End;
end;

function TSERTTKDeputyIDEOptProcMgr.GetArea: String;
begin
  result := '';
end;

function TSERTTKDeputyIDEOptProcMgr.GetCaption: String;
begin
  result := caption_opt_label_proc_mgr;
end;

function TSERTTKDeputyIDEOptProcMgr.GetFrameClass: TCustomFrameClass;
begin
  result := TfrmDeputyOptProcMgr;
end;

function TSERTTKDeputyIDEOptProcMgr.GetHelpContext: Integer;
begin
  result := 0;
end;

function TSERTTKDeputyIDEOptProcMgr.IncludeInIDEInsight: Boolean;
begin
  result := true;
end;

function TSERTTKDeputyIDEOptProcMgr.ValidateContents: Boolean;
begin
  result := true;
end;

end.
