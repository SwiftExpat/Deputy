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
  object sbMain: TStatusBar
    Left = 0
    Top = 615
    Width = 815
    Height = 19
    Panels = <
      item
        Text = 'Idle'
        Width = 50
      end>
  end
  object pcWorkarea: TPageControl
    Left = 0
    Top = 41
    Width = 815
    Height = 574
    ActivePage = tsStatus
    Align = alClient
    TabOrder = 1
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
      end
      object lbMgrStatus: TListBox
        Left = 0
        Top = 447
        Width = 807
        Height = 97
        Align = alBottom
        ItemHeight = 15
        TabOrder = 1
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
    object btnForceTerminate: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Force Terminate'
      TabOrder = 0
      OnClick = btnForceTerminateClick
    end
  end
  object pnlCleanStatus: TPanel
    Left = 328
    Top = 328
    Width = 185
    Height = 41
    Caption = 'pnlCleanStatus'
    ShowCaption = False
    TabOrder = 3
    object lblPollCount: TLabel
      Left = 64
      Top = 8
      Width = 66
      Height = 15
      Caption = 'lblPollCount'
    end
    object btnAbortCleanup: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Abort Cleanup'
      TabOrder = 0
      OnClick = btnAbortCleanupClick
    end
  end
  object tmrCleanupStatus: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrCleanupStatusTimer
    Left = 400
    Top = 328
  end
end
