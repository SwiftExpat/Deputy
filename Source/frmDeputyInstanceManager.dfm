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
    Left = 0
    Top = 0
    Width = 618
    Height = 65
    Align = alTop
    Alignment = taCenter
    Caption = '!! 2 Delphi IDE instances !!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3937500
    Font.Height = -48
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 549
  end
  object btnCloseOriginal: TButton
    Left = 96
    Top = 152
    Width = 281
    Height = 41
    Caption = 'Close Original Instance'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnCloseOriginalClick
  end
  object btnCloseInstance: TButton
    Left = 96
    Top = 88
    Width = 281
    Height = 41
    Caption = 'Close This Instance'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = btnCloseInstanceClick
  end
  object btnHideMessage: TButton
    Left = 96
    Top = 216
    Width = 281
    Height = 41
    Caption = 'Ignore Instance'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
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
