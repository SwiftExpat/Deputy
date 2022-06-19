object DeputyProcMgr: TDeputyProcMgr
  Left = 0
  Top = 0
  Caption = 'DeputyProcMgr'
  ClientHeight = 424
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object memoLeak: TMemo
    Left = 121
    Top = 0
    Width = 497
    Height = 308
    Align = alClient
    Lines.Strings = (
      'memoLeak')
    TabOrder = 0
    ExplicitLeft = 232
    ExplicitTop = 200
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 405
    Width = 618
    Height = 19
    Panels = <
      item
        Text = 'Idle'
        Width = 50
      end>
    ExplicitLeft = 320
    ExplicitTop = 232
    ExplicitWidth = 0
  end
  object lbMgrParams: TListBox
    Left = 0
    Top = 0
    Width = 121
    Height = 308
    Align = alLeft
    ItemHeight = 15
    TabOrder = 2
    ExplicitLeft = 264
    ExplicitTop = 192
    ExplicitHeight = 97
  end
  object lbMgrStatus: TListBox
    Left = 0
    Top = 308
    Width = 618
    Height = 97
    Align = alBottom
    ItemHeight = 15
    TabOrder = 3
    ExplicitLeft = 264
    ExplicitTop = 192
    ExplicitWidth = 121
  end
end
