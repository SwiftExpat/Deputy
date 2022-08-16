object DeputyProcMgr: TDeputyProcMgr
  Left = 0
  Top = 0
  Caption = 'Deputy Process Manager'
  ClientHeight = 634
  ClientWidth = 815
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
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
    Top = 0
    Width = 815
    Height = 615
    ActivePage = tsStatus
    Align = alClient
    TabOrder = 1
    object tsStatus: TTabSheet
      Caption = 'Status'
      object memoLeakStatus: TMemo
        Left = 0
        Top = 97
        Width = 807
        Height = 488
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object lbMgrStatus: TListBox
        Left = 0
        Top = 0
        Width = 807
        Height = 97
        Align = alTop
        ItemHeight = 15
        TabOrder = 1
      end
    end
    object tsHistory: TTabSheet
      Caption = 'History'
      ImageIndex = 2
      object lvHist: TListView
        Left = 0
        Top = 0
        Width = 807
        Height = 120
        Align = alTop
        Checkboxes = True
        Columns = <
          item
            AutoSize = True
            Caption = 'Process'
          end
          item
            AutoSize = True
            Caption = 'Start'
          end
          item
            AutoSize = True
            Caption = 'Stop'
          end
          item
            AutoSize = True
            Caption = 'Elapsed ms'
          end
          item
            AutoSize = True
            Caption = 'Proc Found'
          end
          item
            AutoSize = True
            Caption = 'Leak Shown'
          end>
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        ViewStyle = vsReport
        OnInfoTip = lvHistInfoTip
        OnSelectItem = lvHistSelectItem
      end
      object memoLeakHist: TMemo
        Left = 0
        Top = 120
        Width = 807
        Height = 465
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
  end
  object gpCleanStatus: TGridPanel
    Left = 328
    Top = 240
    Width = 185
    Height = 80
    BorderWidth = 1
    BorderStyle = bsSingle
    Caption = 'gpCleanStatus'
    ColumnCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = lblHdrLoopCount
        Row = 0
      end
      item
        Column = 1
        Control = lblLoopCount
        Row = 0
      end
      item
        Column = 1
        Control = btnAbortCleanup
        Row = 2
      end
      item
        Column = 0
        Control = lblHdrElapsed
        Row = 1
      end
      item
        Column = 1
        Control = lblElapsedMS
        Row = 1
      end
      item
        Column = 0
        Control = btnForceTerminate
        Row = 2
      end>
    RowCollection = <
      item
        Value = 27.028124982687920000
      end
      item
        Value = 31.804834819149520000
      end
      item
        Value = 41.167040198162570000
      end>
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object lblHdrLoopCount: TLabel
      Left = 2
      Top = 2
      Width = 88
      Height = 19
      Align = alClient
      Alignment = taRightJustify
      Caption = 'Loop Count ='
      ExplicitLeft = 16
      ExplicitWidth = 74
      ExplicitHeight = 15
    end
    object lblLoopCount: TLabel
      Left = 90
      Top = 2
      Width = 89
      Height = 19
      Align = alClient
      Caption = 'lblLoopCount'
      ExplicitWidth = 73
      ExplicitHeight = 15
    end
    object btnAbortCleanup: TButton
      AlignWithMargins = True
      Left = 92
      Top = 45
      Width = 86
      Height = 28
      Margins.Left = 2
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Align = alClient
      Caption = 'Abort Cleanup'
      TabOrder = 0
      OnClick = btnAbortCleanupClick
    end
    object lblHdrElapsed: TLabel
      Left = 2
      Top = 21
      Width = 88
      Height = 23
      Align = alClient
      Alignment = taRightJustify
      Caption = 'Elapsed ms = '
      ExplicitLeft = 17
      ExplicitWidth = 73
      ExplicitHeight = 15
    end
    object lblElapsedMS: TLabel
      Left = 90
      Top = 21
      Width = 89
      Height = 23
      Align = alClient
      Caption = '0'
      ExplicitWidth = 6
      ExplicitHeight = 15
    end
    object btnForceTerminate: TButton
      AlignWithMargins = True
      Left = 3
      Top = 45
      Width = 85
      Height = 28
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 2
      Margins.Bottom = 1
      Align = alClient
      Caption = 'Force Terminate'
      TabOrder = 1
      OnClick = btnForceTerminateClick
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
