object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object Button1: TButton
      Left = 272
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 502
      Top = 1
      Width = 121
      Height = 39
      Align = alRight
      TabOrder = 1
      Text = 'RTTK.VCL.exe'
      ExplicitHeight = 23
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 624
    Height = 400
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
end
