unit frmDeputyOptionsInstance;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ToolsAPI, SERTTK.DeputyTypes;

const
  caption_options_label = 'Deputy Options';

type

  TfrmDeputyOptInstance = class(TFrame)
    rgInstanceManager: TRadioGroup;
    procedure rgInstanceManagerClick(Sender: TObject);
  private
    FSettings: TSERTTKDeputySettings;
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
{ TfrmDeputyOptInstance }

procedure TfrmDeputyOptInstance.FinalizeFrame;
begin

end;

procedure TfrmDeputyOptInstance.InitializeFrame;
begin
  if Assigned(FSettings) then
  begin
    if FSettings.DetectSecondInstance then
      rgInstanceManager.ItemIndex := 1
    else
      rgInstanceManager.ItemIndex := 0
  end;
end;

procedure TfrmDeputyOptInstance.rgInstanceManagerClick(Sender: TObject);
begin
  if rgInstanceManager.ItemIndex = 0 then
    FSettings.DetectSecondInstance := false
  else
    FSettings.DetectSecondInstance := true;
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
