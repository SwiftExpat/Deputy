object DeputyProcMgr: TDeputyProcMgr
  Left = 0
  Top = 0
  Caption = 'DeputyProcMgr'
  ClientHeight = 634
  ClientWidth = 815
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object StatusBar1: TStatusBar
    Left = 0
    Top = 615
    Width = 815
    Height = 19
    Panels = <
      item
        Text = 'Idle'
        Width = 50
      end>
    ExplicitTop = 405
    ExplicitWidth = 618
  end
  object pcWorkarea: TPageControl
    Left = 0
    Top = 41
    Width = 815
    Height = 574
    ActivePage = tsStatus
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 176
    ExplicitTop = 144
    ExplicitWidth = 289
    ExplicitHeight = 193
    object tsParameters: TTabSheet
      Caption = 'Parameters'
      object lbMgrParams: TListBox
        Left = 0
        Top = 0
        Width = 807
        Height = 544
        Align = alClient
        ItemHeight = 15
        TabOrder = 0
        ExplicitWidth = 121
        ExplicitHeight = 308
      end
    end
    object tsStatus: TTabSheet
      Caption = 'Status'
      ImageIndex = 1
      object memoLeak: TMemo
        Left = 0
        Top = 0
        Width = 807
        Height = 447
        Align = alClient
        Lines.Strings = (
          'memoLeak')
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitWidth = 618
        ExplicitHeight = 308
      end
      object lbMgrStatus: TListBox
        Left = 0
        Top = 447
        Width = 807
        Height = 97
        Align = alBottom
        ItemHeight = 15
        TabOrder = 1
        ExplicitTop = 308
        ExplicitWidth = 618
      end
    end
  end
  object FlowPanel1: TFlowPanel
    Left = 0
    Top = 0
    Width = 815
    Height = 41
    Align = alTop
    Caption = 'FlowPanel1'
    TabOrder = 2
    ExplicitLeft = 312
    ExplicitTop = 272
    ExplicitWidth = 185
    object btnAbortManager: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Abort Deputy'
      TabOrder = 0
      OnClick = btnAbortManagerClick
    end
    object btnForceTerminate: TButton
      Left = 76
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Force Terminate'
      TabOrder = 1
      OnClick = btnForceTerminateClick
    end
  end
  object tmrCleanupBegin: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrCleanupBeginTimer
    Left = 400
    Top = 328
  end
end
