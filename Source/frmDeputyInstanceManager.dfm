object DeputyInstanceManager: TDeputyInstanceManager
  Left = 0
  Top = 0
  Caption = 'Deputy Instance Manager'
  ClientHeight = 424
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Label1: TLabel
    Left = 96
    Top = 32
    Width = 175
    Height = 15
    Caption = 'Two Delphi IDE instances running'
  end
  object btnCloseOriginal: TButton
    Left = 96
    Top = 152
    Width = 145
    Height = 25
    Caption = 'Close Original Instance'
    TabOrder = 0
    OnClick = btnCloseOriginalClick
  end
  object btnCloseInstance: TButton
    Left = 96
    Top = 88
    Width = 145
    Height = 25
    Caption = 'Close This Instance'
    TabOrder = 1
    OnClick = btnCloseInstanceClick
  end
  object btnHideMessage: TButton
    Left = 96
    Top = 216
    Width = 145
    Height = 25
    Caption = 'Ignore Instance'
    TabOrder = 2
    OnClick = btnHideMessageClick
  end
  object memoLog: TMemo
    Left = 0
    Top = 280
    Width = 618
    Height = 144
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 3
  end
end
