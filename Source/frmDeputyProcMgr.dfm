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
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
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
        Lines.Strings = (
          'memoLeakHist')
        ScrollBars = ssBoth
        TabOrder = 1
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
        TabOrder = 1
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
      object gpTimeouts: TGridPanel
        Left = 16
        Top = 160
        Width = 257
        Height = 82
        BorderWidth = 1
        BorderStyle = bsSingle
        ColumnCollection = <
          item
            Value = 60.000000000000000000
          end
          item
            Value = 40.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            ColumnSpan = 2
            Control = lblHdrTimeouts
            Row = 0
          end
          item
            Column = 0
            Control = lblWaitPollTimeout
            Row = 1
          end
          item
            Column = 1
            Control = edtWaitPoll
            Row = 1
          end
          item
            Column = 0
            Control = lblHdrShowDelay
            Row = 2
          end
          item
            Column = 1
            Control = edtShowDelay
            Row = 2
          end>
        RowCollection = <
          item
            Value = 24.606826166973400000
          end
          item
            Value = 38.689978249958170000
          end
          item
            Value = 36.703195583068430000
          end>
        ShowCaption = False
        TabOrder = 5
        object lblHdrTimeouts: TLabel
          Left = 2
          Top = 2
          Width = 249
          Height = 18
          Align = alClient
          Alignment = taCenter
          Caption = 'Process Manager Timeouts'
          ExplicitWidth = 142
          ExplicitHeight = 15
        end
        object lblWaitPollTimeout: TLabel
          Left = 2
          Top = 20
          Width = 149
          Height = 28
          Align = alClient
          Alignment = taCenter
          Caption = 'WaitPoll Interval (ms)'
          Layout = tlCenter
          ExplicitWidth = 113
          ExplicitHeight = 15
        end
        object edtWaitPoll: TSpinEdit
          AlignWithMargins = True
          Left = 154
          Top = 23
          Width = 71
          Height = 24
          MaxValue = 200
          MinValue = 25
          TabOrder = 0
          Value = 25
          OnChange = edtWaitPollChange
        end
        object lblHdrShowDelay: TLabel
          Left = 2
          Top = 48
          Width = 149
          Height = 28
          Align = alClient
          Caption = 'Show Manager Delay (ms)'
          Layout = tlCenter
          ExplicitTop = 49
          ExplicitWidth = 138
          ExplicitHeight = 15
        end
        object edtShowDelay: TSpinEdit
          AlignWithMargins = True
          Left = 154
          Top = 51
          Width = 94
          Height = 24
          MaxValue = 1500
          MinValue = 100
          TabOrder = 1
          Value = 200
          OnChange = edtShowDelayChange
        end
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
      Top = 44
      Width = 86
      Height = 29
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
      Height = 22
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
      Height = 22
      Align = alClient
      Caption = '0'
      ExplicitWidth = 6
      ExplicitHeight = 15
    end
    object btnForceTerminate: TButton
      AlignWithMargins = True
      Left = 3
      Top = 44
      Width = 85
      Height = 29
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
