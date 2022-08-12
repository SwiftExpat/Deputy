unit frmDeputyOptProcessManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsAPI, SERTTK.DeputyTypes, Vcl.ExtCtrls;

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
    LinkLabel1: TLinkLabel;
  strict private
    FSettings: TSERTTKDeputySettings;
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

procedure TfrmDeputyOptProcMgr.FinalizeFrame;
begin

end;

procedure TfrmDeputyOptProcMgr.InitializeFrame;
begin

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
