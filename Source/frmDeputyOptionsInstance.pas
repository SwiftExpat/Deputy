unit frmDeputyOptionsInstance;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ToolsAPI, SERTTK.DeputyTypes;

const
  caption_options_label = 'Deputy';
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

  TfrmDeputyOptInstance = class(TFrame)
    lblHeader: TLabel;
    llDocumentation: TLinkLabel;
    gpInstOptions: TGridPanel;
    llOpenSourceAcknowledge: TLinkLabel;
    pnlOpenSource: TPanel;
    llOpenSourceCommit: TLinkLabel;
  private
    FSettings: TSERTTKDeputySettings;
    procedure LinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
  public
    property DeputySettings: TSERTTKDeputySettings read FSettings write FSettings;
    procedure InitializeFrame;
    procedure FinalizeFrame;
  end;

  TSERTTKDeputyIDEOptionsInterface = Class(TInterfacedObject, INTAAddInOptions)
  Strict Private
    FFrame: TfrmDeputyOptInstance;
    FSettings: TSERTTKDeputySettings;
  Strict Protected
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

uses SERTTK.DeputyExpert;
{ TfrmDeputyOptInstance }

procedure TfrmDeputyOptInstance.FinalizeFrame;
begin

end;

procedure TfrmDeputyOptInstance.InitializeFrame;
begin
  llOpenSourceCommit.Caption := 'Built with Total commit <a href="' + TOTAL_URL + '">' + TOTAL_COMMIT + '</a>' +
    ' and Kastri commit <a href="' + Kastri_URL + '">' + Kastri_COMMIT + '</a>';
  llOpenSourceCommit.OnLinkClick := LinkClick;
  llOpenSourceAcknowledge.OnLinkClick := LinkClick;
  llDocumentation.OnLinkClick := LinkClick;
end;

procedure TfrmDeputyOptInstance.LinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
var
  du: TSERTTKDeputyUtils;
begin
  if LinkType = TSysLinkType.sltURL then
  begin
    du := TSERTTKDeputyUtils.Create;
    du.ShowUrl(Link);
    du.Free;
  end;
end;

{ TSERTTKDeputyIDEOptionsInterface }

procedure TSERTTKDeputyIDEOptionsInterface.DialogClosed(Accepted: Boolean);
begin
  if Accepted then
    FFrame.FinalizeFrame;
end;

procedure TSERTTKDeputyIDEOptionsInterface.FrameCreated(AFrame: TCustomFrame);
begin
  If AFrame Is TfrmDeputyOptInstance Then
  Begin
    FFrame := AFrame As TfrmDeputyOptInstance;
    FFrame.DeputySettings := DeputySettings;
    FFrame.InitializeFrame;
  End;
end;

function TSERTTKDeputyIDEOptionsInterface.GetArea: String;
begin // return empty to place under third party
  result := '';
end;

function TSERTTKDeputyIDEOptionsInterface.GetCaption: String;
begin
  result := caption_options_label;
end;

function TSERTTKDeputyIDEOptionsInterface.GetFrameClass: TCustomFrameClass;
begin
  result := TfrmDeputyOptInstance;
end;

function TSERTTKDeputyIDEOptionsInterface.GetHelpContext: Integer;
begin
  result := 0;
end;

function TSERTTKDeputyIDEOptionsInterface.IncludeInIDEInsight: Boolean;
begin
  result := true;
end;

function TSERTTKDeputyIDEOptionsInterface.ValidateContents: Boolean;
begin // called when OK is selected
  result := true;
end;

end.
