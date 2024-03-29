unit frmDeputyOptUpdates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, ToolsAPI, SERTTK.DeputyTypes, Vcl.Dialogs, Vcl.ExtCtrls;

const
  caption_opt_label_updates = 'Deputy.Updates';
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
  TfrmDeputyOptUpdate = class(TFrame)
    LinkLabel1: TLinkLabel;
  strict private
    FSettings: TSERTTKDeputySettings;
  public
    property DeputySettings: TSERTTKDeputySettings read FSettings write FSettings;
    procedure InitializeFrame;
    procedure FinalizeFrame;
  end;

  TSERTTKDeputyIDEOptUpdates = Class(TInterfacedObject, INTAAddInOptions)
  Strict Private
    FFrame: TfrmDeputyOptUpdate;
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
{ TfrmDeputyOptUpdate }

procedure TfrmDeputyOptUpdate.FinalizeFrame;
begin

end;

procedure TfrmDeputyOptUpdate.InitializeFrame;
begin

end;

{ TSERTTKDeputyIDEOptUpdates }

procedure TSERTTKDeputyIDEOptUpdates.DialogClosed(Accepted: Boolean);
begin
  if Accepted then
    FFrame.FinalizeFrame;
end;

procedure TSERTTKDeputyIDEOptUpdates.FrameCreated(AFrame: TCustomFrame);
begin
  If AFrame Is TfrmDeputyOptUpdate Then
  Begin
    FFrame := AFrame As TfrmDeputyOptUpdate;
    FFrame.DeputySettings := DeputySettings;
    FFrame.InitializeFrame;
  End;
end;

function TSERTTKDeputyIDEOptUpdates.GetArea: String;
begin
  result := '';
end;

function TSERTTKDeputyIDEOptUpdates.GetCaption: String;
begin
  result := caption_opt_label_updates;
end;

function TSERTTKDeputyIDEOptUpdates.GetFrameClass: TCustomFrameClass;
begin
  result := TfrmDeputyOptUpdate;
end;

function TSERTTKDeputyIDEOptUpdates.GetHelpContext: Integer;
begin
  result := 0;
end;

function TSERTTKDeputyIDEOptUpdates.IncludeInIDEInsight: Boolean;
begin
  result := true;
end;

function TSERTTKDeputyIDEOptUpdates.ValidateContents: Boolean;
begin
  result := true;
end;

end.
