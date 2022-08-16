unit frmDeputyOptInstanceManager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsAPI, SERTTK.DeputyTypes, Vcl.StdCtrls, Vcl.ExtCtrls;

const
  caption_opt_label_inst_mgr = 'Deputy.Instance Manager';
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
  TfrmDeputyOptInstMgr = class(TFrame)
    lblDeputyInstMgrHeader: TLabel;
    rgInstanceManager: TRadioGroup;
    procedure rgInstanceManagerClick(Sender: TObject);
  strict private
    FSettings: TSERTTKDeputySettings;
  public
    property DeputySettings: TSERTTKDeputySettings read FSettings write FSettings;
    procedure InitializeFrame;
    procedure FinalizeFrame;
  end;

  TSERTTKDeputyIDEOptInstMgr = Class(TInterfacedObject, INTAAddInOptions)
  Strict Private
    FFrame: TfrmDeputyOptInstMgr;
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
{ TfrmDeputyOptInstMgr }

procedure TfrmDeputyOptInstMgr.FinalizeFrame;
begin

end;

procedure TfrmDeputyOptInstMgr.InitializeFrame;
begin
     if Assigned(FSettings) then
  begin
    if FSettings.DetectSecondInstance then
      rgInstanceManager.ItemIndex := 1
    else
      rgInstanceManager.ItemIndex := 0
  end;
end;

procedure TfrmDeputyOptInstMgr.rgInstanceManagerClick(Sender: TObject);
begin
  if rgInstanceManager.ItemIndex = 0 then
    FSettings.DetectSecondInstance := false
  else
    FSettings.DetectSecondInstance := true;
end;

{ TSERTTKDeputyIDEOptInstMgr }

procedure TSERTTKDeputyIDEOptInstMgr.DialogClosed(Accepted: Boolean);
begin
  if Accepted then
    FFrame.FinalizeFrame;
end;

procedure TSERTTKDeputyIDEOptInstMgr.FrameCreated(AFrame: TCustomFrame);
begin
  If AFrame Is TfrmDeputyOptInstMgr Then
  Begin
    FFrame := AFrame As TfrmDeputyOptInstMgr;
    FFrame.DeputySettings := DeputySettings;
    FFrame.InitializeFrame;
  End;
end;

function TSERTTKDeputyIDEOptInstMgr.GetArea: String;
begin
  result := '';
end;

function TSERTTKDeputyIDEOptInstMgr.GetCaption: String;
begin
  result := caption_opt_label_inst_mgr;
end;

function TSERTTKDeputyIDEOptInstMgr.GetFrameClass: TCustomFrameClass;
begin
  result := TfrmDeputyOptInstMgr;
end;

function TSERTTKDeputyIDEOptInstMgr.GetHelpContext: Integer;
begin
  result := 0;
end;

function TSERTTKDeputyIDEOptInstMgr.IncludeInIDEInsight: Boolean;
begin
  result := true;
end;

function TSERTTKDeputyIDEOptInstMgr.ValidateContents: Boolean;
begin
  result := true;
end;

end.
