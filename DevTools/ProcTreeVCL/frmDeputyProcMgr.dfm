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
    ActivePage = tsSettings
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
        Lines.Strings = (
          'memoLeak')
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitTop = 0
        ExplicitHeight = 447
      end
      object lbMgrStatus: TListBox
        Left = 0
        Top = 0
        Width = 807
        Height = 97
        Align = alTop
        ItemHeight = 15
        TabOrder = 1
        ExplicitTop = 447
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
        ExplicitLeft = 208
        ExplicitTop = 312
        ExplicitWidth = 466
        ExplicitHeight = 150
      end
      object memoLeakHist: TMemo
        Left = 0
        Top = 120
        Width = 807
        Height = 465
        Align = alClient
        Lines.Strings = (
          'memoLeakHist')
        ScrollBars = ssBoth
        TabOrder = 1
        ExplicitHeight = 424
      end
    end
    object tsSettings: TTabSheet
      Caption = 'Settings'
      ImageIndex = 2
      object rgProcStopCommand: TRadioGroup
        Left = 232
        Top = 32
        Width = 185
        Height = 105
        Caption = 'Terminate Action'
        Items.Strings = (
          'Terminate'
          'Close')
        TabOrder = 0
        OnClick = rgProcStopCommandClick
      end
      object Memo1: TMemo
        Left = 0
        Top = 496
        Width = 807
        Height = 89
        Align = alBottom
        Lines.Strings = (
          'Memo1')
        TabOrder = 1
        ExplicitLeft = 312
        ExplicitTop = 248
        ExplicitWidth = 185
      end
      object rgProcTermActive: TRadioGroup
        Left = 16
        Top = 32
        Width = 185
        Height = 105
        Caption = 'Proc Terminate'
        Items.Strings = (
          'Enabled'
          'Disabled')
        TabOrder = 2
        OnClick = rgProcTermActiveClick
      end
      object cbCloseLeakWindow: TCheckBox
        Left = 448
        Top = 56
        Width = 179
        Height = 17
        Caption = 'Close Leak Window'
        TabOrder = 3
        OnClick = cbCloseLeakWindowClick
      end
      object cbCopyLeakMessage: TCheckBox
        Left = 448
        Top = 108
        Width = 145
        Height = 17
        Caption = 'Copy Leak Message'
        TabOrder = 4
        OnClick = cbCopyLeakMessageClick
      end
    end
  end
  object gpCleanStatus: TGridPanel
    Left = 328
    Top = 240
    Width = 185
    Height = 64
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
        Control = lblLCHdr
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
        Control = Label1
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
    object lblLCHdr: TLabel
      Left = 1
      Top = 1
      Width = 92
      Height = 17
      Align = alClient
      Alignment = taRightJustify
      Caption = 'Loop Count ='
      ExplicitLeft = 19
      ExplicitWidth = 74
      ExplicitHeight = 15
    end
    object lblLoopCount: TLabel
      Left = 93
      Top = 1
      Width = 91
      Height = 17
      Align = alClient
      Caption = 'lblLoopCount'
      ExplicitWidth = 73
      ExplicitHeight = 15
    end
    object btnAbortCleanup: TButton
      Left = 93
      Top = 37
      Width = 91
      Height = 26
      Align = alClient
      Caption = 'Abort Cleanup'
      TabOrder = 0
      Visible = False
      OnClick = btnAbortCleanupClick
    end
    object Label1: TLabel
      Left = 1
      Top = 18
      Width = 92
      Height = 19
      Align = alClient
      Alignment = taRightJustify
      Caption = 'Elapsed ms = '
      ExplicitLeft = 20
      ExplicitWidth = 73
      ExplicitHeight = 15
    end
    object lblElapsedMS: TLabel
      Left = 93
      Top = 18
      Width = 91
      Height = 19
      Align = alClient
      Caption = '0'
      ExplicitWidth = 6
      ExplicitHeight = 15
    end
    object btnForceTerminate: TButton
      Left = 1
      Top = 37
      Width = 92
      Height = 26
      Align = alClient
      Caption = 'Force Terminate'
      TabOrder = 1
      Visible = False
      OnClick = btnForceTerminateClick
      ExplicitTop = 1
      ExplicitWidth = 75
      ExplicitHeight = 25
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
