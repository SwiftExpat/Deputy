object DeputyUpdates: TDeputyUpdates
  Left = 0
  Top = 0
  Caption = 'Deputy Updates'
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
  object gpUpdates: TGridPanel
    Left = 0
    Top = 0
    Width = 618
    Height = 172
    Align = alTop
    Caption = 'gpUpdates'
    ColumnCollection = <
      item
        Value = 18.974025974025970000
      end
      item
        Value = 32.168831168831170000
      end
      item
        Value = 30.285714285714290000
      end
      item
        Value = 18.571428571428570000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = lblHdrItem
        Row = 0
      end
      item
        Column = 1
        Control = lblHdrVerCurr
        Row = 0
      end
      item
        Column = 3
        Control = lblHdrUpdate
        Row = 0
      end
      item
        Column = 2
        Control = lblHdrVerAvail
        Row = 0
      end
      item
        Column = 0
        Control = lblDeputy
        Row = 1
      end
      item
        Column = 0
        Control = lblCaddie
        Row = 2
      end
      item
        Column = 0
        Control = lblDemoFMX
        Row = 3
      end
      item
        Column = 0
        Control = lblDemoVCL
        Row = 4
      end
      item
        Column = 1
        Control = lblDeputyInst
        Row = 1
      end
      item
        Column = 2
        Control = lblDeputyAvail
        Row = 1
      end
      item
        Column = 3
        Control = btnUpdateDeputy
        Row = 1
      end
      item
        Column = 1
        Control = lblCaddieInst
        Row = 2
      end
      item
        Column = 2
        Control = lblCaddieAvail
        Row = 2
      end
      item
        Column = 3
        Control = btnUpdateCaddie
        Row = 2
      end
      item
        Column = 1
        Control = lblDemoFmxInst
        Row = 3
      end
      item
        Column = 2
        Control = lblDemoFMXAvail
        Row = 3
      end
      item
        Column = 3
        Control = btnUpdateDemoFMX
        Row = 3
      end
      item
        Column = 1
        Control = lblDemoVCLInst
        Row = 4
      end
      item
        Column = 2
        Control = lblDemoVCLAvail
        Row = 4
      end
      item
        Column = 3
        Control = btnUpdateDemoVCL
        Row = 4
      end
      item
        Column = 0
        Control = lblHdrUpdateRefresh
        Row = 5
      end
      item
        Column = 1
        Control = lblUpdateRefresh
        Row = 5
      end>
    RowCollection = <
      item
        Value = 16.847349113286680000
      end
      item
        Value = 16.464092102564930000
      end
      item
        Value = 16.632262927820000000
      end
      item
        Value = 16.942616389030450000
      end
      item
        Value = 16.735897562942610000
      end
      item
        Value = 16.377781904355330000
      end>
    ShowCaption = False
    TabOrder = 0
    object lblHdrItem: TLabel
      Left = 1
      Top = 1
      Width = 117
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'Item'
      ExplicitWidth = 24
      ExplicitHeight = 15
    end
    object lblHdrVerCurr: TLabel
      Left = 118
      Top = 1
      Width = 198
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'Current Version'
      ExplicitWidth = 81
      ExplicitHeight = 15
    end
    object lblHdrUpdate: TLabel
      Left = 503
      Top = 1
      Width = 114
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'Update'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblHdrVerAvail: TLabel
      Left = 316
      Top = 1
      Width = 187
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'Available Version'
      ExplicitWidth = 89
      ExplicitHeight = 15
    end
    object lblDeputy: TLabel
      Left = 1
      Top = 30
      Width = 117
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'Deputy'
      ExplicitWidth = 38
      ExplicitHeight = 15
    end
    object lblCaddie: TLabel
      Left = 1
      Top = 58
      Width = 117
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'Caddie'
      ExplicitWidth = 37
      ExplicitHeight = 15
    end
    object lblDemoFMX: TLabel
      Left = 1
      Top = 86
      Width = 117
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'FMX Demo'
      ExplicitWidth = 59
      ExplicitHeight = 15
    end
    object lblDemoVCL: TLabel
      Left = 1
      Top = 115
      Width = 117
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'VCL Demo'
      ExplicitWidth = 56
      ExplicitHeight = 15
    end
    object lblDeputyInst: TLabel
      Left = 118
      Top = 30
      Width = 198
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'DeputyInst'
      ExplicitWidth = 57
      ExplicitHeight = 15
    end
    object lblDeputyAvail: TLabel
      Left = 316
      Top = 30
      Width = 187
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'deputyavail'
      ExplicitWidth = 61
      ExplicitHeight = 15
    end
    object btnUpdateDeputy: TButton
      AlignWithMargins = True
      Left = 506
      Top = 33
      Width = 108
      Height = 22
      Align = alClient
      Caption = 'Update Deputy'
      TabOrder = 0
      OnClick = btnUpdateDeputyClick
    end
    object lblCaddieInst: TLabel
      Left = 118
      Top = 58
      Width = 198
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'caddieInst'
      ExplicitWidth = 54
      ExplicitHeight = 15
    end
    object lblCaddieAvail: TLabel
      Left = 316
      Top = 58
      Width = 187
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'CaddieAvail'
      ExplicitWidth = 63
      ExplicitHeight = 15
    end
    object btnUpdateCaddie: TButton
      AlignWithMargins = True
      Left = 506
      Top = 61
      Width = 108
      Height = 22
      Align = alClient
      Caption = 'Update Caddie'
      TabOrder = 1
      OnClick = btnUpdateCaddieClick
    end
    object lblDemoFmxInst: TLabel
      Left = 118
      Top = 86
      Width = 198
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'fmxInst'
      ExplicitWidth = 40
      ExplicitHeight = 15
    end
    object lblDemoFMXAvail: TLabel
      Left = 316
      Top = 86
      Width = 187
      Height = 29
      Align = alClient
      Alignment = taCenter
      Caption = 'FmxAvail'
      ExplicitWidth = 49
      ExplicitHeight = 15
    end
    object btnUpdateDemoFMX: TButton
      AlignWithMargins = True
      Left = 506
      Top = 89
      Width = 108
      Height = 23
      Align = alClient
      Caption = 'Update FMX Demo'
      TabOrder = 2
      OnClick = btnUpdateDemoFMXClick
    end
    object lblDemoVCLInst: TLabel
      Left = 118
      Top = 115
      Width = 198
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'vclInst'
      ExplicitWidth = 34
      ExplicitHeight = 15
    end
    object lblDemoVCLAvail: TLabel
      Left = 316
      Top = 115
      Width = 187
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'vclAvail'
      ExplicitWidth = 41
      ExplicitHeight = 15
    end
    object btnUpdateDemoVCL: TButton
      AlignWithMargins = True
      Left = 506
      Top = 118
      Width = 108
      Height = 22
      Align = alClient
      Caption = 'Update VCL Demo'
      TabOrder = 3
      OnClick = btnUpdateDemoVCLClick
    end
    object lblHdrUpdateRefresh: TLabel
      Left = 1
      Top = 143
      Width = 117
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = 'Last Update Refresh'
      ExplicitWidth = 104
      ExplicitHeight = 15
    end
    object lblUpdateRefresh: TLabel
      Left = 118
      Top = 143
      Width = 198
      Height = 28
      Align = alClient
      Alignment = taCenter
      Caption = '00:00:00'
      ExplicitWidth = 42
      ExplicitHeight = 15
    end
  end
  object memoMessages: TMemo
    Left = 0
    Top = 172
    Width = 618
    Height = 252
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
end
