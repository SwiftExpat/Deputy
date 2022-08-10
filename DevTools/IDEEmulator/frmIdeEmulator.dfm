object frmIdeEmulate: TfrmIdeEmulate
  Left = 0
  Top = 0
  Caption = 'Ide Emulator'
  ClientHeight = 454
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Memo1: TMemo
    Left = 0
    Top = 199
    Width = 788
    Height = 255
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
    ExplicitTop = 216
    ExplicitWidth = 794
  end
  object btnCheckRunning: TButton
    Left = 136
    Top = 64
    Width = 153
    Height = 25
    Caption = 'Check Running'
    TabOrder = 1
    OnClick = btnCheckRunningClick
  end
end
