object frmIdeEmulate: TfrmIdeEmulate
  Left = 0
  Top = 0
  Caption = 'Ide Emulator'
  ClientHeight = 471
  ClientWidth = 794
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
    Top = 216
    Width = 794
    Height = 255
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
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
